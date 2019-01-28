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
