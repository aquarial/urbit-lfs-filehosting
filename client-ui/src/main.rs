#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use] extern crate rocket;

use std::collections::HashMap;
use std::sync::{Mutex};

use rocket::{State};
use rocket::request::{FromRequest, Request, Outcome};
use rocket::response::{Redirect};
use rocket_contrib::templates::Template;

use reqwest::blocking::{Client};

struct AuthToken {}

struct Info {
    auth_key: Mutex<Option<String>>,
    client: Client,
}

impl Info {
    fn new() -> Self {
        Info {
            auth_key: Mutex::new(None),
            client: Client::new(),
        }
    }
}

#[get("/")]
fn start(state: State<Info>) -> Template {
    let mut context = HashMap::<String,String>::new();
    context.insert("url".into(), "http://localhost:8081".into());
    Template::render("index", &context)
}

#[get("/login?<url>&<token>")]
fn login(state: State<Info>, url: String, token: String) -> Redirect {
    let url2: String = format!("{}/~/login", url);
    println!("Curling to {}", url2);
    let res = state.client
        .post(url2)
        .body(format!("password={}", token))
        .send();

    println!("Got response {:?}", res);
    match res {
        Ok(res) => {
            if let Some(cookie) = res.headers().get("set-cookie") {
                if let Ok(s) = cookie.to_str() {
                    if let Some(s) = s.split(";").next() {
                        let mut key = state.auth_key.lock().unwrap();
                        *key = Some(s.into());
                        return Redirect::to(uri!(manage));
                    }
                }
            }
            println!("Couldn't find set-cookie");
            println!("  got headers {:?}", res.headers());
        },
        Err(err) => {
            println!("error while loggin in: {:?}", err);
        }
    }
    return Redirect::to(uri!(start));
}

#[get("/manage")]
fn manage(state: State<Info>) -> Template {
    let mut context = HashMap::<String,String>::new();

    let res = state.client
        .post(url2)
        .body(format!("password={}", token))
        .send();

    println!("Got response {:?}", res);
    match res {
        Ok(res) => {
        }
        Err(er) => {
        }
    }


    let key = state.auth_key.lock().unwrap();
    println!("using key = {:?}", key);
    Template::render("manage", &context)
}

fn main() {
    std::fs::create_dir_all("./files/").unwrap();
    rocket::ignite()
        .manage(Info::new())
        .mount("/", routes![start, login, manage])
        .attach(Template::fairing())
        .launch();
}
