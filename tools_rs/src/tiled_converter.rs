use std::env;

use xmltree::Element;

fn get_tile_palettes(tileset_filename: &str) -> Vec<u32> {
    let tileset_contents = std::fs::read_to_string(tileset_filename).unwrap();
    let tileset= Element::parse(tileset_contents.as_bytes()).unwrap();
    let mut tile_palettes = Vec::<u32>::new();
    for c in &tileset.children {
        let c_e = c.as_element().unwrap();
        if c_e.name != "tile" {
            continue;
        }
        let mut palette = 0;
        for p in &c_e.get_child("properties").unwrap().children {
            let p_e = p.as_element().unwrap();
            assert!(p_e.name == "property");
            let name_attr = p_e.attributes.get("name").unwrap();
            if name_attr == "palette" {
                let value_attr = p_e.attributes.get("value").unwrap();
                palette =
                    value_attr.parse::<u32>().expect(&format!("palette parse error: {}", value_attr));
            }
        }
        tile_palettes.push(palette);
    }
    return tile_palettes;
}

fn convert_with_xmltree() {
    let args: Vec<String> = env::args().collect();
    let filename = args[1].clone();
    let tileset_filename = args[2].clone();
    let contents = std::fs::read_to_string(filename).unwrap();
    let mut tiled_map = Element::parse(contents.as_bytes()).unwrap();
    // let tileset_filename = tiled_map.get_child("tileset").unwrap().attributes.get("source").unwrap();
    let tile_palettes = get_tile_palettes(&tileset_filename);
    loop {
        let maybe_layer = tiled_map.take_child("layer");
        if maybe_layer.is_none() {
            break;
        }
        let layer = maybe_layer.unwrap();
        println!("; layer: {}", layer.attributes.get("name").unwrap());
        let tile_map_data = layer.get_child("data").unwrap().get_text().unwrap();
        for t in tile_map_data.split(|c: char| c == ',' || c.is_whitespace()) {
            if t == "" {
                continue;
            }
            let mut t = t.parse::<usize>().expect(&format!("parse error: {}", t));
            if t > 0 {
                // Tiled is 1-indexed for tiles, EXCEPT that Tiled uses the 0
                // index for "no tile", which for us is the same as our actual
                // 0-th tile, the transparent one.
                t = t - 1;
            }
            let palette = tile_palettes[t];
            let tile_data = (t as u16) | (palette as u16).rotate_right(3);
            println!("\tdc.w ${:X}", tile_data);
        }
    }
    
    println!("; Enemies");
    let object_group = tiled_map.get_child("objectgroup");
    if object_group.is_none() {
        println!("\tdc.w 0");
        return;  // we're done, no enemies
    }
    let object_group = object_group.unwrap();
    println!("; start enemies");
    let mut enemy_strings = Vec::<String>::new();
    for c in &object_group.children {
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