part of persistent_object;
class _ValueConverter{  
  PersistentList persistentList;
  _ValueConverter(this.persistentList);
  
   convertValue(value) {
    var result;
    if (value == null) {
      return null;
    } 
    if (value is Map) {
      return objectory.map2Object(persistentList.elementType, value); 
    }
    if (value is DbRef) {
      return objectory.dbRef2Object(value);
    }
  }
}
class PersistentIterator<T> implements Iterator<T> {
  Iterator _it;
  _ValueConverter valueConverter;
  PersistentList persistentList;
  PersistentIterator(this.persistentList,this._it, this.valueConverter);  
  T next() => valueConverter.convertValue(_it.next());
  bool hasNext() => _it.hasNext();
}

class PersistentList<T> implements List<T>{
  bool isEmbeddedObject = false;
  PersistentObject parent;
  String pathToMe;
  String elementType;
  List _list;
//  set internalList(List value) => _list = value;
  List get internalList => _list;
  _ValueConverter valueConverter;
  PersistentList._internal(this.parent, this.elementType, this.pathToMe) {
    if (parent.map[pathToMe] == null) {
      parent.map[pathToMe] = [];      
    }
    _list = parent.map[pathToMe];
    if (objectory.newInstance(elementType) is EmbeddedPersistentObject) {
      isEmbeddedObject = true;
    }
    valueConverter = new _ValueConverter(this);
  }  
  factory PersistentList(PersistentObject parent, String elementType, String pathToMe) {
    PersistentList result = parent._compoundProperties[pathToMe];   
    if (result == null) {      
      result = new PersistentList._internal(parent,elementType,pathToMe);
      parent._compoundProperties[pathToMe] = result;  
    }
    return result;
  }
  toString() => "PersistentList($_list)";
  
  void setDirty(String propertyName) {
    parent.setDirty(pathToMe);    
  }
  
  
  internValue(T value) {  
    if (value is EmbeddedPersistentObject) {
      value.parent = parent;
      value.pathToMe = pathToMe;
      return value.map;
    }
    if (value is RootPersistentObject) {
      return value.dbRef;
    }
    return value;
  }
    
    
  bool isEmpty() => _list.isEmpty();
  
  void forEach(void f(element)) => _list.forEach(f);
  
  Collection map(f(T element)) => _list.map(f);
  
  Collection<T> filter(bool f(T element)) => _list.filter(f);
  
  bool every(bool f(T element)) => _list.every(f);
  
  bool some(bool f(T element)) => _list.some(f);
  
  Iterator<T> iterator() => new PersistentIterator(this,_list.iterator(),valueConverter);
  
  int indexOf(T element, [int start = 0]) => _list.indexOf(element, start);
  
  int lastIndexOf(T element, [int start]) => _list.lastIndexOf(element, start);
  
  int get length => _list.length;
  
  List getRange(int start, int length) => _list.getRange(start, length);
  
  void add(T element){
    _list.add(internValue(element));
    setDirty(null);
  }
  
  void remove(T element){
    if (_list.indexOf(element) == -1) return;
    _list.removeRange(_list.indexOf(element), 1);
    setDirty(null);
  }
  
  void addAll(Collection<T> elements){
    _list.addAll(elements);
    setDirty(null);    
  }
  
  void clear(){
    Collection<T> c = _list;
    _list.clear();
    setDirty(null);
  }
  
  T removeLast(){
    T item = _list.last();    
    _list.removeLast();
    setDirty(null);
    return item;
  }
  
  T last() => _list.last();
  
  void sort(int compare(a, b)) => _list.sort(compare);
  
  void insertRange(int start, int length, [T initialValue]){
    _list.insertRange(start, length, initialValue);
    setDirty(null);
  }
  
  void addLast(T value) => _list.addLast(value);
  
  void removeRange(int start, int length){    
    _list.removeRange(start, length);    
    setDirty(null);
  }
  
  void setRange(int start, int length, List<T> from, [int startFrom]){    
    _list.setRange(start, length, from, startFrom);    
    setDirty(null);
  }
  void set length(int newLength) {   
    _list.length = newLength;
  }
  T removeAt(int index) => _list.removeAt(index);
  Dynamic reduce(Dynamic initialValue,
                 Dynamic combine(Dynamic previousValue, T element)) => _list.reduce(initialValue, combine);

  
  void operator[]=(int index, T value){
    _list[index] = internValue(value);
    setDirty(null);
  }
  
  T operator[](int index) {
    return valueConverter.convertValue(_list[index]);
  }
  
  
}