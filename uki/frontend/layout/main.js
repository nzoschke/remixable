include('../layout.js');

var SongRender = uki.extend({}, uki.view.list.Render, {
  render: function(data, rect, i) {
    return '<div style="line-height: ' + rect.height + 'px; font-size: 12px; padding: 0 4px;">' + data.artist + ' - ' + data.title + '</div>';
  }
});


frontend.layout.main = function() {
  var data = ['this is', '300 long', 'list'];
  for (var i=3; i < 300; i++) {
    data[i] = 'item #' + (i+1);
  };
  
  return uki({
    view: 'Box',
    rect: '960 640', anchors: 'left top',
    background: '#EEE',
    childViews: [{
      view: 'ScrollableList', id: 'playlists',
      rect: '200 640', anchors: 'left top bottom',
      rowHeight: 30,
      throttle: 0, multiselect: true, textSelectable: false,
      data: data
    },
    {
      view: 'ScrollableList', id: 'artists',
      rect: '200 0 160 640', anchors: 'left top bottom',
      rowHeight: 30,
      throttle: 0, multiselect: true, textSelectable: false,
      data: data
    },
    {
      view: 'ScrollableList', id: 'albums',
      rect: '360 0 160 640', anchors: 'left top bottom',
      rowHeight: 30,
      throttle: 0, multiselect: true, textSelectable: false,
      data: data
    },
    {
      view: 'ScrollableList', id: 'playlist',
      rect: '520 0 440 640', anchors: 'left top bottom',
      rowHeight: 30,
      throttle: 0, multiselect: true, textSelectable: false,
      data: data, render: SongRender
    }]
  });
}