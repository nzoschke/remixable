include('../layout.js');

var SongRender = uki.extend({}, uki.view.list.Render, {
  render: function(data, rect, i) {
    return '<div style="line-height: ' + rect.height + 'px; font-size: 12px; padding: 0 4px;">' + decodeURIComponent(data['path']) + '</div>';
  }
});

frontend.layout.main = function() {
  sampleData = [{data: 'Loading...'}]

  return uki({
    view: 'HSplitPane',
    rect: '960 640', anchors: 'left top',
    handlePosition: 192 * 2, leftMin: 192, rightMin: 192 * 2, handleWidth: 5,
    background: '#EEE',
    leftChildViews: [{
      view: 'VSplitPane',
      rect: '960 640', anchors: 'left top right bottom',
      handlePosition: 320, leftMin: 160, rightMin: 160, handleWidth: 5,
      topChildViews: [{
        view: 'ScrollPane',
        rect: '384 320', anchors: 'left top right bottom',
        childViews: [{
          view: 'uki.more.view.TreeList', id: 'folders', 
          rect: '384 320', anchors: 'left top right bottom',
          rowHeight: 22,
          style: {fontSize: '12px'},
          multiselect: true,
          data: sampleData
        }]
      }]
    }],
    rightChildViews: [{
      view: 'ScrollPane',
      rect: '576 640', anchors: 'left top right bottom',
      childViews: [{
        view: 'List', id: 'songs',
        rect: '576 640', anchors: 'left top right bottom',
        rowHeight: 22,
        style: {fontSize: '12px'},
        render: SongRender
      }]
    }]
  });
}