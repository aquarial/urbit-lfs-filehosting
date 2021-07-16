#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;

use std::io::Read;
use std::fs::File;
use std::collections::{HashMap, HashSet};

use async_lock::{Mutex, RwLock};

use rocket::{State, Data};
use rocket::http::Status;
use rocket::response::{Response};
use rocket::response::status::NotFound;
use rocket::request::{FromRequest, Request, Outcome};
use rocket::data::ToByteUnit;

use reqwest::Client;

static mut AUTH_KEY: String = String::new();

struct AuthToken {}

#[derive(Debug)]
enum AuthTokenError { InvalidToken }

#[rocket::async_trait]
impl<'r> FromRequest<'r> for AuthToken {
    type Error = AuthTokenError;

    async fn from_request(request: &'r Request<'_>) -> Outcome<Self, Self::Error> {
        let token = request.headers().get_one("authtoken");
        if let Some(token) = token {
            let key = unsafe { &AUTH_KEY };
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
    //download_paths: RwLock<HashMap<String, ()>>,
    provider_url: Mutex<Option<String>>,
    client: Client,
}

impl Info {
    fn new() -> Self {
        Info {
            upload_paths: RwLock::new(HashMap::new()),
            provider_url: Mutex::new(None),
            client: Client::new(),
            // TODO allow adding alternate paths to download a file?
            //download_paths: RwLock::new(HashMap::new()),
        }
    }
}

#[get("/")]
fn default() -> &'static str {
    "fileserver online\n"
}

#[get("/secure")]
fn default_secure(tok: AuthToken) -> &'static str {
    "fileserver secure\n"
}

#[post("/setup", data = "<data>")]
async fn setup_provider(_tok: AuthToken, state: &State<Info>, data: Data<'_>) -> &'static str {
    let provider = data.open(1000.bytes()).into_string().await.unwrap().into_inner();
    let mut url = state.provider_url.lock().await;
    *url = Some(provider);
    let mut ups = state.upload_paths.write().await;
    ups.clear();
    "setup provider\n"
}



#[post("/upload/new/<key>/<space>")]
async fn upload_new(_tok: AuthToken, state: &State<Info>, key: String, space: u64) -> &'static str {
    let mut ups = state.upload_paths.write().await;
    println!("available for uploading {} bytes with {}", space, key);
    ups.insert(key, space);
    "upload path active\n"
}


// #[options("/upload/file/<_key>")]
// fn options_handler<'a>(_key: String) -> &'static str {
//     ""
// }
// 
// #[post("/upload/file/<key>", data = "<data>")]
// fn upload_file(state: State<Info>, key: String, data: Data) -> &'static str {
//     if key.contains("..") {
//         return "invalid key\n";
//     }
//     let mut ups = state.upload_paths.write().unwrap();
//     match ups.remove(&key) {
//         Some(size) => {
//             // TODO handle file-system errors
//             let mut f = File::create(format!("./files/{}", key)).unwrap();
//             let written = data.open(size.bytes()).stream_precise_to(&mut f).unwrap();
//             f.sync_all().unwrap();
// 
//             let url = state.provider_url.lock().unwrap();
//             let auth: &str = &*AUTH_KEY.read().unwrap();
//             let url2: String = format!("{}/~lfs/completed/{}/{}/padding", (*url).as_ref().unwrap(), key, hoon_format_num(written));
//             println!("curling to {}", url2);
//             let res = state.client
//                 .post(url2)
//                 .header("authtoken", auth)
//                 .send();
// 
//             match res {
//                 Ok(res) => {
//                     println!("Got resposne: {:?}", res);
//                     if res.status() == 200 {
//                         println!("uploaded file {}", key);
//                         std::mem::drop(ups);
//                         return "uploaded\n";
//                     } else {
//                         println!("Error uploading {}", key);
//                         ups.insert(key, size);
//                     }
//                 },
//                 Err(err) => {
//                     println!("Error uploading {}: {:?}", key, err);
//                     ups.insert(key, size);
//                 }
//             }
//             return "could not confirm upload with provider. try again when it's online\n"
//         }
//         None => {
//             println!("no path to upload {}", key);
//             return "no such path\n";
//         }
//     }
// }
// 
// fn hoon_format_num(n: u64) -> String {
//     if n >= 1000 {
//         let mut s = hoon_format_num(n / 1000);
//         s.push_str(&format!(".{:0>3}", n % 1000));
//         s
//     } else {
//         format!("{}", n)
//     }
// }
// 
// 
// #[get("/download/file/<key>")]
// fn download_file(key: String) -> Result<NamedFile, NotFound<String>> {
//     // TODO: any other security concerns?
//     if key.contains("..") || key.contains("/") {
//         return Err(NotFound("invalid path".into()));
//     }
//     NamedFile::open(&format!("./files/{}", key)).map_err(|e| NotFound(e.to_string()))
// }


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

//#[delete("/upload/remove/<key>")]
//fn upload_remove(_tok: AuthToken, state: State<Info>, key: String) -> &'static str {
//    if key.contains("..") {
//        return "invalid key\n";
//    }
//    let mut ups = state.upload_paths.write().unwrap();
//    println!("removing upload path to {}", key);
//    ups.remove(&key);
//    std::fs::remove_file(format!("./files/{}", key)).unwrap();
//    "upload path removed\n"
//}

#[launch]
fn rocket() -> _ {
    let args: HashSet<String> = std::env::args().map(|s| s.to_ascii_lowercase()).collect();

    {
        let key: String = if args.contains("--unsafe_debug_auth") {
            "hunter2".into()
        } else {
            generate_password(60)
        };
        println!("Authorized Header is {}", key);
        unsafe {
            AUTH_KEY = key;
        }
    }
    // args.contains("--add-cors-headers")

    std::fs::create_dir_all("./files/").unwrap();
    rocket::build()
        .manage(Info::new())
        .mount("/", routes![default, default_secure, setup_provider, upload_new])
    //  .mount("/", routes![default, upload_new, upload_file, upload_remove, download_file, setup_provider, options_handler])
}
