include('../layout.js');

frontend.layout.main = function() {
  var data = ['this is', '30000k long', 'list'];
  for (var i=3; i < 30000; i++) {
    data[i] = 'item #' + (i+1);
  };
  
  return uki({
    view: 'Box',
    rect: '960 640', anchors: 'left top',
    background: '#EEE',
    childViews: [{
      view: 'ScrollableList', id: 'playlists',
      rect: '200 640', anchors: 'left top bottom', 
      data: data, rowHeight: 30, id: 'list', throttle: 0, multiselect: true, textSelectable: false
    },
    {
      view: 'ScrollableList', id: 'artists',
      rect: '200 0 160 640', anchors: 'left top bottom', 
      data: data, rowHeight: 30, id: 'list', throttle: 0, multiselect: true, textSelectable: false
    },
    {
      view: 'ScrollableList', id: 'albums',
      rect: '360 0 160 640', anchors: 'left top bottom', 
      data: data, rowHeight: 30, id: 'list', throttle: 0, multiselect: true, textSelectable: false
    },
    {
      view: 'ScrollableList', id: 'playlist',
      rect: '520 0 440 640', anchors: 'left top bottom', 
      data: data, rowHeight: 30, id: 'list', throttle: 0, multiselect: true, textSelectable: false
    }]
  });
}