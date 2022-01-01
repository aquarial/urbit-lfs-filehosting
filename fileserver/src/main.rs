#[macro_use] extern crate rocket;

pub mod cors;

use std::borrow::Cow;
use std::collections::{HashMap, HashSet};

use async_lock::{Mutex, RwLock};

use rocket::{State, Data};
use rocket::http::Status;
use rocket::data::ToByteUnit;
use rocket::request::{FromRequest, Request, Outcome};

use rocket::fs::{NamedFile};
use rocket::response::status::{NotFound};

use rocket::serde::{json::Json};
use serde::{Deserialize};

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




#[get("/")]
fn default() -> &'static str {
    "fileserver online\n"
}

#[get("/secure")]
fn default_secure(_tok: AuthToken) -> &'static str {
    "fileserver secure\n"
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



#[derive(Deserialize)]
struct InfoSetupProvider<'r> { url: Cow<'r, str> }

#[post("/setup", data = "<info>")]
async fn setup_provider(_tok: AuthToken, state: &State<Info>, info: Json<InfoSetupProvider<'_>>) -> &'static str {
    let mut url = state.provider_url.lock().await;
    *url = Some(info.url.to_string());

    let mut ups = state.upload_paths.write().await;
    ups.clear();

    "setup provider\n"
}




#[derive(Deserialize)]
struct InfoUploadNew<'r> { file_id: Cow<'r, str>, size: Cow<'r, str>, }

#[post("/upload/new", data = "<info>")]
async fn upload_new(_tok: AuthToken, state: &State<Info>, info: Json<InfoUploadNew<'_>>) -> (Status, &'static str) {
    if info.file_id.contains("..") {
        return (Status::Conflict, "invalid file_id\n");
    }
    // TODO cleaner valid number checking. safe to parse now tho
    if !info.size.bytes().all(|c| b'0' <= c && c <= b'9') || info.size.len() > 15 {
        return (Status::Conflict, "invalid size\n");
    }
    let mut ups = state.upload_paths.write().await;
    println!("available for uploading {} bytes with {}", info.size, info.file_id);
    ups.insert(info.file_id.to_string(), info.size.parse().unwrap());
    return (Status::Accepted, "upload path active\n");
}




#[derive(Deserialize)]
struct InfoUploadRemove<'r> { file_id: Cow<'r, str>, }

#[delete("/upload/remove", data = "<info>")]
async fn upload_remove(_tok: AuthToken, state: &State<Info>, info: Json<InfoUploadRemove<'_>>) -> (Status, &'static str) {
    if info.file_id.contains("..") {
        return (Status::Conflict, "invalid file_id\n");
    }
    let mut ups = state.upload_paths.write().await;
    println!("removing upload path to {}", info.file_id);
    ups.remove(&info.file_id.to_string());
    std::fs::remove_file(format!("./files/{}", info.file_id)).unwrap();
    return (Status::Accepted, "upload path removed\n");
}





#[options("/upload/file/<_key>")]
async fn options_handler<'a>(_key: String) -> &'static str {
    ""
}

#[post("/upload/file/<key>", data = "<data>")]
async fn upload_file(state: &State<Info>, key: String, data: Data<'_>) -> (Status, &'static str) {
    if key.contains("..") {
        return (Status::Conflict, "invalid key\n");
    }
    let mut ups = state.upload_paths.write().await;
    match ups.remove(&key) {
        Some(size) => {
            // TODO handle file-system errors
            let thefile = data.open(size.bytes()).into_file(format!("./files/{}", key)).await.unwrap();
            thefile.sync_all().await.unwrap();
            let written = thefile.metadata().await.unwrap().len();

            let url = state.provider_url.lock().await;
            let auth: &str = unsafe { &AUTH_KEY };
            let url2: String = format!("{}/~lfs-provider/completed/{}/{}/padding", (*url).as_ref().unwrap(), key, hoon_format_num(written));
            println!("curling to {}", url2);
            let res = state.client
                .post(url2)
                .header("authtoken", auth)
                .send()
                .await;

            match res {
                Ok(res) => {
                    if res.status() == 200 {
                        println!("uploaded file {}", key);
                        return (Status::Accepted, "uploaded\n");
                    } else {
                        println!("Error uploading {}: {:?}", key, res);
                        ups.insert(key.clone(), size);
                    }
                },
                Err(err) => {
                    println!("Error uploading {}: {:?}", key, err);
                    ups.insert(key.clone(), size);
                }
            }
            std::fs::remove_file(format!("./files/{}", key)).unwrap();
            return (Status::Conflict, "could not confirm upload with provider. try again when it's online\n");
        }
        None => {
            println!("no path to upload {}", key);
            return (Status::Conflict, "no such path\n");
        }
    }
}

fn hoon_format_num(n: u64) -> String {
    if n >= 1000 {
        let mut s = hoon_format_num(n / 1000);
        s.push_str(&format!(".{:0>3}", n % 1000));
        s
    } else {
        format!("{}", n)
    }
}


#[get("/download/file/<key>")]
async fn download_file(key: String) -> Result<NamedFile, NotFound<String>> {
    // TODO: any other security concerns?
    if key.contains("..") || key.contains("/") {
        return Err(NotFound("invalid path".into()));
    }
    NamedFile::open(&format!("./files/{}", key)).await.map_err(|_| NotFound("invalid fileid".to_string()))
}


fn generate_password(len: usize) -> String {
    use rand::Rng;
    let mut rng = rand::thread_rng();

    const CHARSET: &[u8] = b"#@%~ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    let password: String = (0..len).map(|_| {
          let idx = rng.gen_range(0..CHARSET.len());
          CHARSET[idx] as char
        })
        .collect();
    password
}

#[launch]
fn rocket() -> _ {
    let args: HashSet<String> = std::env::args().map(|s| s.to_ascii_lowercase()).collect();

    let key: String = if args.contains("--unsafe_debug_auth") {
        "hunter2".into()
    } else {
        generate_password(60)
    };
    println!("Authorized Header is {}", key);
    unsafe {
        AUTH_KEY = key;
    }

    std::fs::create_dir_all("./files/").unwrap();
    rocket::build()
        .manage(Info::new())
        .mount("/", routes![default, default_secure, upload_new, upload_file, upload_remove, download_file, setup_provider, options_handler])
        .attach(cors::CORS { enabled: args.contains("--add-cors-headers")})

    // Can't use built in FileServer::server() because it determines src directory at compile time.
    // //  .mount("/download/file", FileServer::from(relative!("files")))
}
