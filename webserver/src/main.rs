#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;

use std::io::Read;
use std::fs::File;
use std::collections::HashMap;
use std::sync::RwLock;

use rocket::State;
use rocket::Data;
use rocket::response::Stream;

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
    "uploaded"
}



#[get("/download/file/<key>")]
fn download_file(key: String) -> Stream<File> {
    let f = File::open(format!("./files/{}", key)).unwrap();
    Stream::from(f)
}


fn main() {
    std::fs::create_dir_all("./files/").unwrap();
    rocket::ignite()
        .manage(Info::new())
        .mount("/", routes![upload_new, upload_file, download_file])
        .launch();
}
