#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;

use std::fs::File;
use std::collections::HashMap;
use std::sync::RwLock;

use lazy_static::lazy_static;

use rocket::{State, Data};
use rocket::http::Status;
use rocket::response::Stream;
use rocket::request::{FromRequest, Request, Outcome};


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
            if key.bytes().zip(token.bytes()).filter(|(a,b)| a != b).count() == 0 {
                return Outcome::Success(AuthToken {})
            }
        }
        return Outcome::Failure((Status::Unauthorized, AuthTokenError::InvalidToken));
    }
}

struct Info {
    upload_paths: RwLock<HashMap<String, ()>>,
    download_paths: RwLock<HashMap<String, ()>>,
}

impl Info {
    fn new() -> Self {
        Info {
            upload_paths: RwLock::new(HashMap::new()),
            download_paths: RwLock::new(HashMap::new()),
        }
    }
}

#[post("/upload/new/<key>")]
fn upload_new(_tok: AuthToken, state: State<Info>, key: String) -> &'static str {
    let mut ups = state.upload_paths.write().unwrap();
    println!("available upload for {}", key);
    ups.insert(key, ());
    "upload path active\n"
}

#[post("/upload/file/<key>", data = "<data>")]
fn upload_file(state: State<Info>, key: String, data: Data) -> &'static str {
    let mut ups = state.upload_paths.write().unwrap();
    match ups.remove(&key) {
        Some(_v) => {
            println!("uploaded file {}", key);
            let mut f = File::create(format!("./files/{}", key)).unwrap();
            data.stream_to(&mut f).unwrap();
            let mut downs = state.download_paths.write().unwrap();
            downs.insert(key, ());
        }
        None => {
            println!("no path to upload {}", key);
        }
    }
    "uploaded\n"
}



#[get("/download/file/<key>")]
fn download_file(key: String) -> Stream<File> {
    let f = File::open(format!("./files/{}", key)).unwrap();
    Stream::from(f)
}

fn main() {
    {
        let mut key = AUTH_KEY.write().unwrap();
        *key = String::from("hunter2");
        println!("Authorized Header is {}", *key);
    }
    std::fs::create_dir_all("./files/").unwrap();
    rocket::ignite()
        .manage(Info::new())
        .mount("/", routes![upload_new, upload_file, download_file])
        .launch();
}
