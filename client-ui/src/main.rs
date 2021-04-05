#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;

use std::io::Read;
use std::fs::File;
use std::collections::HashMap;
use std::sync::{Mutex, RwLock};

use rocket::{State, Data};
use rocket::http::Status;
use rocket::response::Stream;
use rocket::request::{FromRequest, Request, Outcome};
use rocket_contrib::templates::Template;

use reqwest::blocking::{Client};

struct AuthToken {}

struct Info {
    auth_key: Option<String>,
}

impl Info {
    fn new() -> Self {
        Info {
            auth_key: None,
        }
    }
}

#[get("/")]
fn login(state: State<Info>) -> Template {
    let mut context = HashMap::<String,String>::new();
    context.insert("token".into(), state.auth_key.clone().unwrap_or("".into()));
    Template::render("index", &context)
}

fn main() {
    std::fs::create_dir_all("./files/").unwrap();
    rocket::ignite()
        .manage(Info::new())
        .mount("/", routes![login])
        .attach(Template::fairing())
        .launch();
}
