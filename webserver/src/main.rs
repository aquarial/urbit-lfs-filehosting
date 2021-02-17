#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;

use std::collections::HashMap;
use std::sync::RwLock;

use rocket::State;
use rocket::Data;

struct Info {
    upload_paths: RwLock<HashMap<String, ()>>,
    download_paths: RwLock<HashMap<String, ()>>
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
fn upload_new(state: State<Info>, key: String) -> &'static str {
    let mut ups = state.upload_paths.write().unwrap();
    println!("available upload for {}", key);
    ups.insert(key, ());
    "upload path active"
}

#[post("/upload/file/<key>", format = "plain", data = "<data>")]
fn upload_file(state: State<Info>, key: String, data: Data) -> &'static str {
    let mut ups = state.upload_paths.write().unwrap();
    match ups.remove(&key) {
        Some(_v) => {
            println!("uploaded file {}", key);
            data.stream_to_file(format!("./files/{}", key)).unwrap();
        }
        None => {
            println!("no path to upload {}", key);
        }
    }
    "uploaded"
}

fn main() {
    rocket::ignite()
        .manage(Info::new())
        .mount("/", routes![upload_new, upload_file])
        .launch();
}
