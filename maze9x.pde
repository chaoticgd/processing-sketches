
final int FREE = 0;
final int WALL = 1;

final int WORLD_WIDTH = 8;
final int WORLD_HEIGHT = 8;
final int WORLD_TILE_SIZE = 32;
final float PLAYER_TURN_SPEED = QUARTER_PI;
final float PLAYER_MOVE_SPEED = 0.1;

int[][] world = new int[][] {
   { WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL },
   { WALL, FREE, FREE, FREE, FREE, FREE, FREE, WALL },
   { WALL, FREE, FREE, FREE, FREE, FREE, FREE, WALL },
   { WALL, FREE, FREE, FREE, FREE, FREE, FREE, WALL },
   { WALL, FREE, FREE, FREE, FREE, WALL, FREE, WALL },
   { WALL, FREE, FREE, FREE, FREE, WALL, WALL, WALL },
   { WALL, FREE, FREE, FREE, FREE, FREE, FREE, WALL },
   { WALL, WALL, WALL, WALL, WALL, WALL, WALL, WALL }
};

PVector player_position = new PVector(WORLD_WIDTH / 2, WORLD_HEIGHT / 2);
float player_direction = 0;

color colorFromTileType(int tile) {
  switch(tile) {
    case FREE: return color(0, 0, 0);
    case WALL: return color(255, 0, 0);
  }
  
  return color(0, 0, 0, 0);
}

void drawMiniMap() {

  // Draw the world.
  for(int x = 0; x < WORLD_WIDTH; x++) {
    for(int y = 0; y < WORLD_HEIGHT; y++) {
      fill(colorFromTileType(world[x][y]));
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
  
  float plane_x = 0;
  float plane_y = 0.66;
  
  for(int i = 0; i < width; i++) {
    float camera_x = 2 * player_position.x / width - 1;
    float ray_dir_x = dir_x + plane_x * player_position.x;
    float ray_dir_y = dir_y + plane_y * player_position.y;
    
    int map_x = (int) player_position.x;
    int map_y = (int) player_position.y;
    
    //map_x = constrain(map_x, 0, WORLD_WIDTH);
    //map_y = constrain(map_y, 0, WORLD_HEIGHT);
    
    float side_dist_x;
    float side_dist_y;
    
    float delta_dist_x = abs(1 / ray_dir_x);
    float delta_dist_y = abs(1 / ray_dir_y);
    float perp_wall_dist;
    
    int step_x;
    int step_y;
    
    int hit = 0;
    int side;
    if(ray_dir_x < 0) {
      step_x = -1;
      side_dist_x = (player_position.x - map_x) * delta_dist_x;
    } else {
      step_x = 1;
      side_dist_x = (map_x + 1.0 - player_position.x) * delta_dist_x;
    }
    
    if(ray_dir_y < 0) {
      step_y = -1;
      side_dist_y = (map_y + 1.0 - player_position.y) * delta_dist_y;
    } else {
      step_y = 1;
      side_dist_y = (map_y + 1.0 - player_position.y) * delta_dist_y;
    }
    
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
      
      if(world[map_x][map_y] > 0) {
        hit = 1;
      }
    }
    
    PVector wall_vec = new PVector(
      sqrt(pow(map_x - player_position.x, 2)),
      sqrt(pow(map_y - player_position.y, 2))
    );
    
    float line_height = 100 / wall_vec.mag();
    
    stroke(255, 255, 255);
    line(i, height / 2 - line_height, i, height / 2 + line_height);
  }
}

void setup() {
  size(1280, 720);
  
}

void draw() {
  background(0, 0, 0);
  drawMiniMap();
  draw3d();
}

void keyPressed() {
  if(key == 'a') {
    player_direction -= PLAYER_TURN_SPEED;
  } else if(key == 'd') {
    player_direction += PLAYER_TURN_SPEED;
  } else if(key == 'w' || key == 's') {
    PVector diff = new PVector(cos(player_direction), sin(player_direction)).mult(PLAYER_MOVE_SPEED);
    
    if(key == 's') {
      diff = diff.rotate(PI);
    }
    
    player_position = player_position.add(diff);
  }
}
