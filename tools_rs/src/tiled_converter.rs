use std::env;
use std::io::Write;
use std::fs::File;
use std::path::Path;

use xmltree::Element;

struct TileData {
    palette: u8,
    priority: bool,
    collision: bool
}
fn get_tile_data(tileset_filename: &str) -> Vec<TileData> {
    let tileset_contents = std::fs::read_to_string(tileset_filename).unwrap();
    let tileset= Element::parse(tileset_contents.as_bytes()).unwrap();
    let mut tile_palettes = Vec::<TileData>::new();
    for c in &tileset.children {
        let c_e = c.as_element().unwrap();
        if c_e.name != "tile" {
            continue;
        }
        let mut palette = 0;
        let mut priority = false;
        let mut collision = false;
        for p in &c_e.get_child("properties").unwrap().children {
            let p_e = p.as_element().unwrap();
            assert!(p_e.name == "property");
            let name_attr = p_e.attributes.get("name").unwrap();
            if name_attr == "palette" {
                let value_attr = p_e.attributes.get("value").unwrap();
                palette =
                    value_attr.parse::<u8>().expect(&format!("palette parse error: {}", value_attr));
            } else if name_attr == "priority" {
                let value_attr = p_e.attributes.get("value").unwrap().to_lowercase();
                if value_attr == "true" {
                    priority = true;
                }
            } else if name_attr == "collision" {
                let value_attr = p_e.attributes.get("value").unwrap().to_lowercase();
                if value_attr == "true" {
                    collision = true;
                }
            }
        }

        tile_palettes.push(TileData { palette: palette, priority: priority, collision: collision});
    }
    return tile_palettes;
}

fn convert_with_xmltree(
    map_filename: &str, tileset_filename: &str,
    asm_map_out: &mut impl Write, asm_collisions_out: &mut impl Write) {
    let contents = std::fs::read_to_string(map_filename).unwrap();
    let mut tiled_map = Element::parse(contents.as_bytes()).unwrap();
    // let tileset_filename = tiled_map.get_child("tileset").unwrap().attributes.get("source").unwrap();
    let tile_data = get_tile_data(&tileset_filename);
    loop {
        let maybe_layer = tiled_map.take_child("layer");
        if maybe_layer.is_none() {
            break;
        }
        let layer = maybe_layer.unwrap();
        write!(asm_map_out, "; layer: {}\n", layer.attributes.get("name").unwrap()).unwrap();
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
            let palette = tile_data[t].palette;
            let priority = tile_data[t].priority as u16;
            let tile_data = (t as u16) | (palette as u16).rotate_right(3) | priority.rotate_right(1);
            write!(asm_map_out, "\tdc.w ${:X}\n", tile_data).unwrap();
        }
    }
    
    write!(asm_map_out, "; Enemies\n").unwrap();
    let object_group = tiled_map.get_child("objectgroup");
    let mut enemy_strings = Vec::<String>::new();
    if object_group.is_some() {
        let object_group = object_group.unwrap();
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
            } else if type_attr == "ogre" {
                enemy_type_num = 2;
            } else if type_attr == "red_seal" {
                enemy_type_num = 3;
            }
            enemy_strings.push(format!("\tdc.w {},{},{}", enemy_type_num, x, y));
        }
    }
    write!(asm_map_out, "\tdc.w {}\n", enemy_strings.len()).unwrap();
    for s in enemy_strings {
        write!(asm_map_out, "{}\n", s).unwrap();
    }

    // tileset collisions
    write!(asm_collisions_out, "; Tile collisions\n").unwrap();
    for t in tile_data {
        write!(asm_collisions_out, "\tdc.w {}\n", t.collision as u8).unwrap();
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let map_filename = args[1].clone();
    let tileset_filename = args[2].clone();
    let mut map_output: Box<dyn Write>;
    let mut collisions_output: Box <dyn Write>;
    if args.len() >= 4 && args[3] == "cout" {
        map_output = Box::new(std::io::stdout());
        collisions_output = Box::new(std::io::stdout());
    } else {
        let map_path = Path::new(&map_filename).with_extension("asm");
        map_output = Box::new(File::create(&map_path).unwrap());
        let tileset_path = Path::new(&tileset_filename);
        let tileset_stem = tileset_path.file_stem();
        let collision_filename = String::from(tileset_stem.unwrap().to_str().unwrap()) + "_collisions.asm";
        let collisions_path = tileset_path.parent().unwrap().join(Path::new(&collision_filename));
        collisions_output = Box::new(File::create(&collisions_path).unwrap());
        println!(
            "Writing the following files:\n{}\n{}",
            map_path.to_str().unwrap(),
            collisions_path.to_str().unwrap());
    }
    convert_with_xmltree(&map_filename, &tileset_filename, &mut map_output, &mut collisions_output);
}