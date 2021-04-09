#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;

use std::io::Read;
use std::fs::File;
use std::collections::HashMap;
use std::sync::{Mutex, RwLock};

use lazy_static::lazy_static;

use rocket::{State, Data};
use rocket::http::Status;
use rocket::response::Stream;
use rocket::request::{FromRequest, Request, Outcome};

use reqwest::blocking::{Client};


lazy_static! {
    static ref AUTH_KEY: RwLock<String> = RwLock::new(String::new());
}

struct AuthToken {}

#[derive(Debug)]
enum AuthTokenError { InvalidToken }

impl<'a, 'r> FromRequest<'a, 'r> for AuthToken {
    type Error = AuthTokenError;

    fn from_request(request: &'a Request<'r>) -> Outcome<Self, Self::Error> {
        let token = request.headers().get_one("auth_token");
        if let Some(token) = token {
            let key = AUTH_KEY.read().unwrap();
            // compare each byte to prevent timing attack
            if key.bytes().zip(token.bytes()).filter(|(a,b)| a != b).count() == 0 {
                return Outcome::Success(AuthToken {})
            }
        }
        return Outcome::Failure((Status::Unauthorized, AuthTokenError::InvalidToken));
    }
}

struct Info {
    upload_paths: RwLock<HashMap<String, u64>>,
    download_paths: RwLock<HashMap<String, ()>>,
    provider_url: Mutex<Option<String>>,
    client: Client,
}

impl Info {
    fn new() -> Self {
        Info {
            upload_paths: RwLock::new(HashMap::new()),
            download_paths: RwLock::new(HashMap::new()),
            provider_url: Mutex::new(None),
            client: Client::new(),
        }
    }
}

#[get("/")]
fn default() -> &'static str {
    "fileserver online\n"
}

#[post("/setup/<provider>")]
fn setup_provider(_tok: AuthToken, state: State<Info>, provider: String) -> &'static str {
    let mut url = state.provider_url.lock().unwrap();
    *url = Some(provider);
    "setup provider\n"
}


#[post("/upload/new/<key>/<space>")]
fn upload_new(_tok: AuthToken, state: State<Info>, key: String, space: u64) -> &'static str {
    let mut ups = state.upload_paths.write().unwrap();
    println!("available for uploading {} bytes with {}", space, key);
    ups.insert(key, space);
    "upload path active\n"
}

#[post("/upload/file/<key>", data = "<data>")]
fn upload_file(state: State<Info>, key: String, data: Data) -> &'static str {
    if key.contains("..") {
        return "invalid key\n";
    }
    let mut ups = state.upload_paths.write().unwrap();
    match ups.remove(&key) {
        Some(size) => {
            // TODO handle file-system errors
            let mut f = File::create(format!("./files/{}", key)).unwrap();
            let written = std::io::copy(&mut data.open().take(size), &mut f).unwrap();
            f.sync_all().unwrap();

            let url = state.provider_url.lock().unwrap();
            let auth: &str = &*AUTH_KEY.read().unwrap();
            let url2: String = format!("http://{}/~lfs/completed/{}/{}", (*url).as_ref().unwrap(), key, written);
            println!("Curling to {}", url2);
            let res = state.client
                .post(url2)
                .header("auth_token", auth)
                .send();

            match res {
                Ok(res) => {
                    println!("Got resposne: {:?}", res);
                    println!("uploaded file {}", key);
                    std::mem::drop(ups);
                    let mut downs = state.download_paths.write().unwrap();
                    downs.insert(String::from(key), ());
                },
                Err(err) => {
                    println!("Error uploading {}: {:?}", key, err);
                    ups.insert(key, size);
                }
            }
            "uploaded\n"
        }
        None => {
            println!("no path to upload {}", key);
            "no such path\n"
        }
    }
}



#[get("/download/file/<key>")]
fn download_file(key: String) -> Option<Stream<File>> {
    // TODO: any other security concerns?
    if key.contains("..") {
        return None;
    }
    let f = File::open(format!("./files/{}", key)).unwrap();
    Some(Stream::from(f))
}


/// https://rust-lang-nursery.github.io/rust-cookbook/algorithms/randomness.html
fn generate_password(len: usize) -> String {
    use rand::Rng;
    const CHARSET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZ\
                             abcdefghijklmnopqrstuvwxyz\
                             0123456789)(*&^%$#@!~<>?";
    let mut rng = rand::thread_rng();

    let password: String = (0..len)
        .map(|_| {
            let idx = rng.gen_range(0..CHARSET.len());
            CHARSET[idx] as char
        })
        .collect();
    password
}

#[delete("/upload/remove/<key>")]
fn upload_remove(_tok: AuthToken, state: State<Info>, key: String) -> &'static str {
    if key.contains("..") {
        return "invalid key\n";
    }
    let mut ups = state.upload_paths.write().unwrap();
    println!("removing upload path to {}", key);
    ups.remove(&key);
    std::fs::remove_file(format!("./files/{}", key)).unwrap();
    "upload path removed\n"
}

fn main() {
    {
        let mut key = AUTH_KEY.write().unwrap();
        if std::env::args().any(|arg| arg == "--UNSAFE_DEBUG_AUTH") {
            *key = "hunter2".into()
        } else {
            *key = generate_password(60);
        }
        println!("Authorized Header is {}", *key);
    }

    std::fs::create_dir_all("./files/").unwrap();
    rocket::ignite()
        .manage(Info::new())
        .mount("/", routes![default, upload_new, upload_file, upload_remove, download_file, setup_provider])
        .launch();
}