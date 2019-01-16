import java.util.Map;

final color ___ = color(0, 0, 0);
final color RED = color(255, 0, 0);
final color YEL = color(255, 255, 0);
final color GRE = color(0, 255, 0);
final color CYA = color(0, 255, 255);
final color BLU = color(0, 0, 255);
final color MAG = color(255, 0, 255);

final int WORLD_WIDTH = 8;
final int WORLD_HEIGHT = 8;
final int WORLD_TILE_SIZE = 32;
final float PLAYER_TURN_SPEED = 0.1;
final float PLAYER_MOVE_SPEED = 0.05;

color[][] world = new color[][] {
   { MAG, RED, MAG, RED, MAG, RED, MAG, RED },
   { RED, ___, BLU, ___, ___, ___, ___, MAG },
   { MAG, ___, CYA, ___, BLU, BLU, ___, RED },
   { RED, ___, GRE, ___, BLU, ___, BLU, MAG },
   { MAG, ___, ___, ___, BLU, ___, ___, RED },
   { RED, ___, BLU, ___, BLU, BLU, ___, MAG },
   { MAG, ___, BLU, ___, ___, ___, ___, RED },
   { RED, MAG, RED, MAG, RED, MAG, RED, MAG }
};

Map<Character, Boolean> keyboardState = new HashMap<Character, Boolean>();

PVector player_position = new PVector(1.5, 1.5);
float player_direction = HALF_PI;

color getTileAt(int x, int y) {
  if(x >= 0 && x < WORLD_WIDTH && y >= 0 && y < WORLD_HEIGHT) {
    return world[y][x];
  } else {
    return RED;
  }
}

void drawMiniMap() {

  // Draw the world.
  stroke(255, 255, 255);
  for(int x = 0; x < WORLD_WIDTH; x++) {
    for(int y = 0; y < WORLD_HEIGHT; y++) {
      fill(world[y][x]);
      rect(x * WORLD_TILE_SIZE, y * WORLD_TILE_SIZE, WORLD_TILE_SIZE, WORLD_TILE_SIZE);
    }
  }
  
  // Draw the player.
  fill(0, 255, 255);
  ellipse(player_position.x * WORLD_TILE_SIZE, player_position.y * WORLD_TILE_SIZE, 16, 16);
  arc(player_position.x * WORLD_TILE_SIZE, player_position.y * WORLD_TILE_SIZE, 32, 32, player_direction - 0.1, player_direction + 0.1);
}

void draw3d() {
  
  // Convert player direction into vector.
  float dir_x = cos(player_direction);
  float dir_y = sin(player_direction);
  
  
  PVector plane = new PVector(dir_y, -dir_x);
  
  for(int i = 0; i < width; i++) {
    float camera_x = 2 * i / (float) width - 1;
    float ray_dir_x = dir_x + plane.x * camera_x;
    float ray_dir_y = dir_y + plane.y * camera_x;
    
    int map_x = (int) player_position.x;
    int map_y = (int) player_position.y;
    
    float side_dist_x;
    float side_dist_y;
    
    float delta_dist_x = abs(1 / ray_dir_x);
    float delta_dist_y = abs(1 / ray_dir_y);
    float perp_wall_dist;
    
    int step_x;
    int step_y;
    
    int hit = 0;
    int side = 0;
    if(ray_dir_x < 0) {
      step_x = -1;
      side_dist_x = (player_position.x - map_x) * delta_dist_x;
    } else {
      step_x = 1;
      side_dist_x = (map_x + 1.0 - player_position.x) * delta_dist_x;
    }
    
    if(ray_dir_y < 0) {
      step_y = -1;
      side_dist_y = (player_position.y - map_y) * delta_dist_y;
    } else {
      step_y = 1;
      side_dist_y = (map_y + 1.0 - player_position.y) * delta_dist_y;
    }
    
    color tile = color(0, 0, 0);
    while(hit == 0) {
      if(side_dist_x < side_dist_y) {
        side_dist_x += delta_dist_x;
        map_x += step_x;
        side = 0;
      } else {
        side_dist_y += delta_dist_y;
        map_y += step_y;
        side = 1;
      }
      
      tile = getTileAt(map_x, map_y);
      if(red(tile) > 0 || green(tile) > 0 || blue(tile) > 0) {
        hit = 1;
      }
    }
    
    if(side == 0) {
      perp_wall_dist = (map_x - player_position.x + (1 - step_x) / 2) / ray_dir_x;
    } else {
      perp_wall_dist = (map_y - player_position.x + (1 - step_y) / 2) / ray_dir_y;
    }
    
    float line_height = 0.5 * height / perp_wall_dist;
    
    float fog = perp_wall_dist * 32;
    if(side == 0) {
      fog += 10;
    }
    stroke(red(tile) - fog, green(tile) - fog, blue(tile) - fog);
    line(i, height / 2 - line_height, i, height / 2 + line_height);
  }
}

void setup() {
  size(1280, 720);
  
  keyboardState.put('w', false);
  keyboardState.put('a', false);
  keyboardState.put('s', false);
  keyboardState.put('d', false);
}

void draw() {
  background(200, 200, 200);
  
  colorMode(HSB);
  for(int y = 0; y < height / 2; y++) {
    int brightness = 255 - 200 * y / height;
    stroke(0, 0, brightness);
    line(0, y, width, y);
    stroke(45, 255, brightness);
    line(0, height - y, width, height - y);
  }
  
  colorMode(RGB);
  draw3d();
  drawMiniMap();
  
  movement();
}

void movement() {
  if(keyboardState.get('a')) {
    player_direction += PLAYER_TURN_SPEED;
  }
  
  if(keyboardState.get('d')) {
    player_direction -= PLAYER_TURN_SPEED;
  }
  
  if(keyboardState.get('w') || keyboardState.get('s')) {
    PVector diff = new PVector(cos(player_direction), sin(player_direction)).mult(PLAYER_MOVE_SPEED);
    
    if(keyboardState.get('s')) {
      diff = diff.rotate(PI);
    }
    
    player_position = player_position.add(diff);
  }
}

void keyPressed() {
  keyboardState.put(key, true);
}

void keyReleased() {
  keyboardState.put(key, false);
}
