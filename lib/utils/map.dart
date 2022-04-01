Map sliceMap(Map map, offset, length) {
  return Map.fromIterable(map.keys.skip(offset).take(length),
      value: (k) => map[k]);
}
