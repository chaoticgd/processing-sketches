/*
	Copyright (c) 2019 chaoticgd

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
*/

import java.util.Map;

final int WORLD_TILE_SIZE = 16;
final float PLAYER_TURN_SPEED = 0.1;
final float PLAYER_MOVE_SPEED = 0.05;

Map<Character, Boolean> keyboardState = new HashMap<Character, Boolean>();

Controller controller = new Player(new PVector(1.5, 1.5), HALF_PI);
World world = new FixedMaze();

void setup() {
  size(1280, 720);
  
  keyboardState.put('w', false);
  keyboardState.put('a', false);
  keyboardState.put('s', false);
  keyboardState.put('d', false);
}

void draw() {
  controller.advance();
  
  colorMode(HSB);
  drawBackground();
  colorMode(RGB);
  draw3d(controller.getPosition(), controller.getDirection());
  drawMiniMap(controller.getPosition(), controller.getDirection());
}

void keyPressed() {
  if(controller instanceof WallFollower) {
    controller = new Player(controller.getPosition(), controller.getDirection());
  }
  
  keyboardState.put(key, true);
}

void keyReleased() {
  keyboardState.put(key, false);
}

static class Heading {

  public static final int EAST = 0;
  public static final int NORTH = 1;
  public static final int WEST = 2;
  public static final int SOUTH = 3;
  
  public Heading(int v) {
    value = v;
  }
  
  public float toAngle() {
    switch(value) {
      case EAST:   return 0;
      case NORTH:  return HALF_PI;
      case WEST:   return PI;
      case SOUTH:  return PI * 1.5;
    }
    return 0;
  }
  
  public static Heading fromVector(int x, int y) {
    if(x > y) {
      if(abs(x) > abs(y)) {
        return new Heading(EAST);
      } else {
        return new Heading(NORTH);
      }
    } else {
      if(abs(x) > abs(y)) {
        return new Heading(WEST);
      } else {
        return new Heading(SOUTH);
      }
    }
  }
  
  public int value;
}

interface Controller {
  public void advance();
  public PVector getPosition();
  public float getDirection();
}

class WallFollower implements Controller {
  
  public void advance() {
    if(interp >= 1) {
      interp = 0;
      lastX = x;
      lastY = y;
      PVector positionVec = nextPosition();
      x = (int) positionVec.x;
      y = (int) positionVec.y;
      
      lastDirection = direction;
      direction = Heading.fromVector(x - lastX, y - lastY);
    } else {
      interp += 0.02;
    }
  }
  
  public PVector getPosition() {
    return new PVector(x, y).mult(interp).add(new PVector(lastX, lastY).mult(1 - interp)).add(0.5, 0.5);
  }
  
  public float getDirection() {
    return lastDirection.toAngle() * (1 - interp) + direction.toAngle() * (interp) + PI;
  }
  
  private PVector nextPosition() {
    
    /*for(int i = 0; i < 4; i++) {
      int absoluteDirection = (i - direction.value + 4) % 4;
      switch(absoluteDirection) {
        case Heading.EAST:  if(!isTileOccupied(x + 1, y)) return new PVector(x + 1, y);
        case Heading.NORTH: if(!isTileOccupied(x, y - 1)) return new PVector(x, y - 1);
        case Heading.WEST:  if(!isTileOccupied(x - 1, y)) return new PVector(x - 1, y);
        case Heading.SOUTH: if(!isTileOccupied(x, y + 1)) return new PVector(x, y + 1);
      }
    }*/
    
    return new PVector(x, y);
  }
  
  private int lastX = 1, lastY = 1;
  private int x = 1, y = 1;
  private Heading lastDirection = new Heading(Heading.WEST);
  private Heading direction = new Heading(Heading.WEST);
  private float interp = 1;
}

class Player implements Controller {
  
  public Player(PVector position, float direction) {
    this.position = position;
    this.direction = direction;
  }
  
  public void advance() {
    if(keyboardState.get('a')) {
      direction += PLAYER_TURN_SPEED;
    }
    
    if(keyboardState.get('d')) {
      direction -= PLAYER_TURN_SPEED;
    }
    
    if(keyboardState.get('w') || keyboardState.get('s')) {
      PVector diff = new PVector(cos(direction), sin(direction)).mult(PLAYER_MOVE_SPEED);
      
      if(keyboardState.get('s')) {
        diff = diff.rotate(PI);
      }
      
      position = position.add(diff);
    }
  }
  public PVector getPosition() {
    return position;
  }
  public float getDirection() {
    return direction;
  }
  
  PVector position;
  float direction;
}


void drawBackground() {
  for(int y = 0; y < height / 2; y++) {
    int brightness = 255 - 200 * y / height;
    stroke(0, 0, brightness);
    line(0, y, width, y);
    stroke(45, 255, brightness);
    line(0, height - y, width, height - y);
  }
}

void drawMiniMap(PVector cameraPosition, float cameraAngle) {

  // Draw the world.
  stroke(255, 255, 255);
  for(int x = 0; x < world.width(); x++) {
    for(int y = 0; y < world.height(); y++) {
      fill(world.getColour(new Point(x, y)));
      rect(x * WORLD_TILE_SIZE, y * WORLD_TILE_SIZE, WORLD_TILE_SIZE, WORLD_TILE_SIZE);
    }
  }
  
  // Draw the player.
  fill(255, 255, 0);
  ellipse(cameraPosition.x * WORLD_TILE_SIZE, cameraPosition.y * WORLD_TILE_SIZE, 8, 8);
  arc(cameraPosition.x * WORLD_TILE_SIZE, cameraPosition.y * WORLD_TILE_SIZE, 16, 16, cameraAngle - 0.4, cameraAngle + 0.4);
}

// Based on https://lodev.org/cgtutor/raycasting.html
void draw3d(PVector cameraPosition, float cameraAngle) {
  
  // Convert player direction into vector.
  float dir_x = cos(cameraAngle);
  float dir_y = sin(cameraAngle);
  
  
  PVector plane = new PVector(dir_y * 0.9, -dir_x);
  
  for(int i = 0; i < width; i++) {
    float camera_x = 2 * i / (float) width - 1;
    float ray_dir_x = dir_x + plane.x * camera_x;
    float ray_dir_y = dir_y + plane.y * camera_x;
    
    int map_x = (int) cameraPosition.x;
    int map_y = (int) cameraPosition.y;
    
    float side_dist_x;
    float side_dist_y;
    
    float delta_dist_x = abs(1 / ray_dir_x);
    float delta_dist_y = abs(1 / ray_dir_y);
    float perp_wall_dist;
    
    int step_x;
    int step_y;
    
    int side = 0;
    if(ray_dir_x < 0) {
      step_x = -1;
      side_dist_x = (cameraPosition.x - map_x) * delta_dist_x;
    } else {
      step_x = 1;
      side_dist_x = (map_x + 1.0 - cameraPosition.x) * delta_dist_x;
    }
    
    if(ray_dir_y < 0) {
      step_y = -1;
      side_dist_y = (cameraPosition.y - map_y) * delta_dist_y;
    } else {
      step_y = 1;
      side_dist_y = (map_y + 1.0 - cameraPosition.y) * delta_dist_y;
    }
    
    while(true) { //for(int j = 0; j < 10; j++) {
      if(side_dist_x < side_dist_y) {
        side_dist_x += delta_dist_x;
        map_x += step_x;
        side = 0;
      } else {
        side_dist_y += delta_dist_y;
        map_y += step_y;
        side = 1;
      }
      
      if(world.isTileOccupied(new Point(map_x, map_y))) {
        break;
      }
    }
    
    if(side == 0) {
      perp_wall_dist = (map_x - cameraPosition.x + (1 - step_x) / 2) / ray_dir_x;
    } else {
      perp_wall_dist = (map_y - cameraPosition.y + (1 - step_y) / 2) / ray_dir_y;
    }
    
    float line_height = 0.5 * height / perp_wall_dist;
    
    int drawStart = int(-line_height / 2 + height / 2);
    if(drawStart < 0) drawStart = 0;
    int drawEnd = int(line_height / 2 + height / 2);
    if(drawEnd >= height) drawEnd = height - 1;
    
    float wallX;
    if (side == 0) {
      wallX = cameraPosition.y + perp_wall_dist * ray_dir_y;
    } else {
      wallX = cameraPosition.x + perp_wall_dist * ray_dir_x;
    }
    wallX -= floor(wallX);

    int texX = int(wallX * float(8));
    if(side == 0 && ray_dir_x > 0) texX = 8 - texX - 1;
    if(side == 1 && ray_dir_x < 0) texX = 8 - texX - 1;
    
    float fog = perp_wall_dist * 32;
    if(side == 0) {
      fog += 10;
    }
    
    float lower = height / 2 - line_height;
    float upper = height / 2 + line_height;
    float diff = (upper - lower) / 16;
    
    for(int j = 0; j < 16; j++) {
      PVector uv = new PVector(texX / 8.0, (j % 8) / 8.0);
      int sample = world.getPixel(new Point(map_x, map_y), uv);
      stroke(red(sample) - fog, green(sample) - fog, blue(sample) - fog);
      line(i, lower + diff * j, i, lower + diff * (j + 1));
    }
  }
}
