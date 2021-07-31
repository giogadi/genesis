use std::env;

use xmltree::Element;

fn convert_with_xmltree() {
    let args: Vec<String> = env::args().collect();
    let filename = args[1].clone();
    let contents = std::fs::read_to_string(filename).unwrap();
    let tiled_map = Element::parse(contents.as_bytes()).unwrap();
    let layer = tiled_map.get_child("layer").unwrap();
    let tile_map_data = layer.get_child("data").unwrap().get_text().unwrap();
    for t in tile_map_data.split(|c: char| c == ',' || c.is_whitespace()) {
        if t == "" {
            continue;
        }
        let t = t.parse::<u32>().expect(&format!("parse error: {}", t)) - 1;
        println!("\tdc.w ${:X}", t );
    }
    println!("; start enemies");
    let mut enemy_strings = Vec::<String>::new();
    for c in &tiled_map.get_child("objectgroup").unwrap().children {
        let e = c.as_element().unwrap();
        assert!(e.name == "object");
        let type_attr = e.attributes.get("type");
        if type_attr.is_none() {
            continue;
        }
        let type_attr = type_attr.unwrap();
        let x = e.attributes.get("x").unwrap().parse::<u32>().unwrap();
        let y = e.attributes.get("y").unwrap().parse::<u32>().unwrap();
        let mut enemy_type_num = 0;
        if type_attr == "butt" {
            enemy_type_num = 0;
        } else if type_attr == "hot_dog" {
            enemy_type_num = 1;
        }
        enemy_strings.push(format!("\tdc.w {},{},{}", enemy_type_num, x, y));
    }
    println!("\tdc.w {}", enemy_strings.len());
    for s in enemy_strings {
        println!("{}", s);
    }
}

fn main() {
    convert_with_xmltree();
}