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
