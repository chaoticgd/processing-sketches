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

interface Renderer {
  void setup();
  void draw(World world, Controller controller);
}

class MiniMapRenderer implements Renderer {
  
  void setup() {}
  
  void draw(World world, Controller controller) {
    // Draw the world.
    stroke(255, 255, 255);
    for(int x = 0; x < world.width(); x++) {
      for(int y = 0; y < world.height(); y++) {
        fill(world.getColour(new Point(x, y)));
        rect(x * WORLD_TILE_SIZE, y * WORLD_TILE_SIZE, WORLD_TILE_SIZE, WORLD_TILE_SIZE);
      }
    }
    
    PVector cameraPosition = controller.getPosition();
    float cameraAngle = controller.getDirection();
    
    // Draw the player.
    fill(255, 255, 0);
    ellipse(cameraPosition.x * WORLD_TILE_SIZE, cameraPosition.y * WORLD_TILE_SIZE, 8, 8);
    arc(cameraPosition.x * WORLD_TILE_SIZE, cameraPosition.y * WORLD_TILE_SIZE, 16, 16, cameraAngle - 0.4, cameraAngle + 0.4);
  }
}

// Based on https://lodev.org/cgtutor/raycasting.html
class RaycastingRenderer implements Renderer {
  
  void setup() {
    size(1280, 720);
  }
  
  void draw(World world, Controller controller) {
    
    PVector cameraPosition = controller.getPosition();
    float cameraAngle = controller.getDirection();
    
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
      
      for(int j = 0; j < 32; j++) {
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
};
