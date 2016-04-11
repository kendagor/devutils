Simplify displaying STL container classes in GDB.

Copy .gdbinit file to ~/.gdbinit

Usage:

Data type                   GDB command

std::vector<T>              pvector stl_variable  
std::list<T>                plist stl_variable T  
std::map<T,T>               pmap stl_variable
std::multimap<T,T>          pmap stl_variable
std::set<T>                 pset stl_variable T
std::multiset<T>            pset stl_variable
std::deque<T>               pdequeue stl_variable
std::stack<T>               pstack stl_variable
std::queue<T>               pqueue stl_variable
std::priority_queue<T>      ppqueue stl_variable
std::bitset<n>td>           pbitset stl_variable
std::string                 pstring stl_variable
std::widestring             pwstring stl_variable
