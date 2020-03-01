#include <stdio.h>
#include <fstream>
#include <string>
#include <cassert>
#include <iostream>
#include <exception>
using namespace std;

class Path {
  string path;
public:
  Path(const char* p2) {
    string p(p2);
    char endch= p.back();
    path= ('/' == endch)? p: p+"/";
  }
  string str() const { return path; }
  operator const char*() const { return path.c_str(); }
};

class BrightnessDrv {
  const unsigned brightness_adjustment_steps;
  Path brightness_path;

  unsigned read_maxbr() const {
    ifstream max_brightness_fl(brightness_path.str() + "max_brightness");
    unsigned curr_maxbr;
    max_brightness_fl >> curr_maxbr;
    return curr_maxbr;
  }
  int read_br() const {
    ifstream brightness_fl(brightness_path.str() + "brightness");
    int curr_br;
    brightness_fl >> curr_br;
    return curr_br;
  }
  void write_br(const int set_br) const {
    if (set_br > static_cast<int>(read_maxbr()) || set_br < 0)
      throw domain_error("Attempted to set brightness="+to_string(set_br)+", which is out of limits!");
    ofstream brightness_fl(brightness_path.str() + "brightness");
    cout << "[write_br]: " << set_br << '\n';
    brightness_fl << set_br;
  }

public:
  BrightnessDrv(Path path, int br_adj_steps):
      brightness_adjustment_steps(br_adj_steps),
      brightness_path(path) {}

  void inc_br(const unsigned steps) const {
    assert(steps <= brightness_adjustment_steps);
    auto max_br= read_maxbr();
    auto step_size= max_br / brightness_adjustment_steps;
    auto new_br= read_br() + steps*step_size;
    new_br= (new_br > max_br)? max_br: new_br;
    write_br(new_br);
  }
  void dec_br(const unsigned steps) const {
    assert(steps <= brightness_adjustment_steps);
    auto step_size= read_maxbr() / brightness_adjustment_steps;
    int new_br= read_br() - steps*step_size;
    new_br= (new_br<0)? 0: new_br;
    write_br(new_br);
  }
  void ch_br(const int steps) const {
    if (steps>0) inc_br(steps);
    if (steps<0) dec_br(-steps);
  }
};

int main(int argc, char** argv) {
  int steps= 0, nSteps= 12;
  if (argc!=2 && argc!=3) {
    cout << "Usage: " << argv[0] << " <+-brightness_steps> [<num_of_steps>]\n";
    return 1;
  }
  if (argc>1)
    steps= atoi(argv[1]);
  if (argc==3)
    nSteps= atoi(argv[2]);
  if (steps!=0){
    BrightnessDrv drv("/sys/class/backlight/intel_backlight",nSteps);
    drv.ch_br(steps);
  }
  return 0;
}
