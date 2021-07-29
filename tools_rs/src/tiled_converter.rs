extern crate xml;

use std::env;

use std::fs::File;
use std::io::BufReader;

use xml::reader::{EventReader, XmlEvent, ParserConfig};

fn main() {
    let args: Vec<String> = env::args().collect();
    let filename = args[1].clone();
    let file = File::open(filename).unwrap();
    let file = BufReader::new(file);

    let parser_config = ParserConfig {
        trim_whitespace: true,
        ..ParserConfig::default()
    };
    let mut parser = EventReader::new_with_config(file, parser_config);
    parser.next().unwrap(); // open document
    parser.next().unwrap(); // open map
    parser.next().unwrap(); // open tileset
    parser.next().unwrap(); // close tileset
    parser.next().unwrap(); // open layer
    parser.next().unwrap(); // open data
    match parser.next() {
        Ok(XmlEvent::Characters(s)) => {
            for t in s.split(|c: char| c == ',' || c.is_whitespace()) {
                if t == "" {
                    continue;
                }
                let t = t.parse::<u32>().expect(&format!("parse error: {}", t)) - 1;
                println!("\tdc.w ${:X}", t );
            }
        }
        _ => {
            println!("UNEXPECTED!");
        }
    }
    println!("; start enemies");
    parser.next().unwrap(); // close data
    parser.next().unwrap(); // close layer
    parser.next().unwrap(); // open objectgroup
    let mut enemyStrings: Vec<String> = Vec::new();
    loop {
        match parser.next().unwrap() {
            XmlEvent::EndElement { name, .. } => {
                assert!(name.local_name == "objectgroup");
                break;
            }
            XmlEvent::StartElement { name, attributes: attr, ..} => {
                assert!(name.local_name == "object");
                // Continue with exporting the rest of the enemy object
                let x = attr[2].value.parse::<i32>().unwrap();
                let y = attr[3].value.parse::<i32>().unwrap();
                let enemy_type = &attr[1].value;
                let mut enemy_type_num = 0;
                if enemy_type == "butt" {
                    enemy_type_num = 0;
                } else if enemy_type == "hot_dog" {
                    enemy_type_num = 1;
                }
                enemyStrings.push(format!("\tdc.w {},{},{}", enemy_type_num, x, y));
                parser.next().unwrap(); // open point
                parser.next().unwrap(); // close point
                parser.next().unwrap(); // close object
            }
            _ => { println!("UNEXPECTED!"); }
        }
    }
    println!("\tdc.w {}", enemyStrings.len());
    for s in enemyStrings {
        println!("{}", s);
    }
    // match parser.next().unwrap() {
    //     XmlEvent::StartElement { name, attributes: attr, ..} => {
    //         assert!(name.local_name == "object");
    //         // Continue with exporting the rest of the enemy object
    //         let x = attr[2].value.parse::<i32>().unwrap();
    //         let y = attr[3].value.parse::<i32>().unwrap();
    //         let enemy_type = &attr[1].value;
    //         let mut enemy_type_num = 0;
    //         if enemy_type == "butt" {
    //             enemy_type_num = 0;
    //         } else if enemy_type == "hot_dog" {
    //             enemy_type_num = 1;
    //         }
    //         println!("\tdc.w ${:X},${:X},${:X}", enemy_type_num, x, y);
    //     }
    //     _ => {
    //         println!("UNEXPECTED");
    //     }
    // }
    // parser.next().unwrap(); // open point
    // parser.next().unwrap(); // close point
    // parser.next().unwrap(); // close object
    // parser.next().unwrap(); // close objectgroup
    parser.next().unwrap(); // close map

    // for e in parser {
    //     match e {
    //         Ok(XmlEvent::StartElement { name, .. }) => {
    //             println!("open {}", name);
    //         }
    //         Ok(XmlEvent::EndElement { name }) => {
    //             println!("close {}", name);
    //         }
    //         Ok(XmlEvent::Characters(s)) => {
    //             println!("CHARS! {}", s.len());
    //             // for t in s.split(|c: char| c == ',' || c.is_whitespace()) {
    //             //     if t == "" {
    //             //         continue;
    //             //     }
    //             //     let t = t.parse::<u32>().expect(&format!("parse error: {}", t)) - 1;
    //             //     println!("\tdc.w ${:X}", t );
    //             // }
    //         }
    //         Ok(XmlEvent::Whitespace(s)) => {
    //             println!("WHITESPACE!");
    //         }
    //         Err(e) => {
    //             println!("Error: {}", e);
    //             break;
    //         }
    //         _ => { println!("HOWDY!"); }
    //     }
    // }
}