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
final float PLAYER_MOVE_SPEED = 0.1;

Map<Character, Boolean> keyboardState = new HashMap<Character, Boolean>();

Controller controller = new Player(new PVector(1.5, 1.5), HALF_PI);
World world = new FixedMaze();
Renderer renderer = new RaycastingRenderer();

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
  renderer.draw(world, controller);
  new MiniMapRenderer().draw(world, controller);
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

void drawBackground() {
  for(int y = 0; y < height / 2; y++) {
    int brightness = 255 - 200 * y / height;
    stroke(0, 0, brightness);
    line(0, y, width, y);
    stroke(45, 255, brightness);
    line(0, height - y, width, height - y);
  }
}
