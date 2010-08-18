include('../layout.js');

var SongRender = uki.extend({}, uki.view.list.Render, {
  render: function(data, rect, i) {
    return '<div style="line-height: ' + rect.height + 'px; font-size: 12px; padding: 0 4px;">' + decodeURIComponent(data['path']) + '</div>';
  },

  setSelected: function(container, data, state, focus) {
      container.style.backgroundColor = state && focus ? '#3875D7' : state ? '#CCC' : '';
      container.style.color = state && focus ? '#FFF' : '#000';
  }
});

frontend.layout.main = function() {
  sampleData = [{data: 'Loading...'}]

  return uki([
    { view: 'Box', id: 'controls',
      rect: '960 64', anchors: 'left top right', background: 'theme(panel)',
      childViews: [
        { view: 'Button', id: 'stop',  rect: '10 10 24 24', anchors: 'left top', text: ' ▇', focusable: false, },
        { view: 'Button', id: 'play',  rect: '34 10 24 24', anchors: 'left top', text: '◀', focusable: false, },
        { view: 'Button', id: 'pause', rect: '58 10 24 24', anchors: 'left top', text: '❙❙', focusable: false, },
        { view: 'Button', id: 'prev',  rect: '82 10 24 24', anchors: 'left top', text: '◀▎', focusable: false, },
        { view: 'Button', id: 'next',  rect: '106 10 24 24', anchors: 'left top', text: '◀▎', focusable: false, },
        { view: 'Button', id: 'rand',  rect: '130 10 24 24', anchors: 'left top', text: '➦', focusable: false, },
        // { view: 'Button', rect: '210 10 200 24', anchors: 'left top', text: '◀▎◀ ▏ ▇ ☐ ▢ ▕▶ </div>', focusable: false, } 
        //       
        // { view: 'Button', rect: '10 10 200 24', anchors: 'left top', text: '⇥ ⇤ ᐀ ᐅ ᑀ ᑅ ⏏', focusable: false },
        // { view: 'Button', rect: '210 10 200 24', anchors: 'left top', text: '◀▎◀ ▏ ▇ ☐ ▢ ▕▶ </div>', focusable: false, } 
      ]
    },
    { view: 'HSplitPane',
      rect: '0 64 960 576', anchors: 'left top right bottom',
      handlePosition: 192 * 2, leftMin: 192, rightMin: 192 * 2, handleWidth: 2,
      background: '#EEE',
      leftChildViews: [{
        view: 'VSplitPane',
        rect: '384 576', anchors: 'left top right bottom',
        handlePosition: 288, leftMin: 160, rightMin: 160, handleWidth: 2,
        topChildViews: [{
          view: 'ScrollPane',
          rect: '384 288', anchors: 'left top right bottom',
          childViews: [{
            view: 'uki.more.view.TreeList', id: 'folders', 
            rect: '384 288', anchors: 'left top right bottom',
            rowHeight: 22,
            style: {fontSize: '12px'},
            multiselect: true,
            data: sampleData
          }]
        }]
      }],
      rightChildViews: [{
        view: 'ScrollPane',
        rect: '574 576', anchors: 'left top right bottom',
        childViews: [{
          view: 'List', id: 'songs',
          rect: '574 576', anchors: 'left top right bottom',
          rowHeight: 22,
          style: {fontSize: '12px'},
          multiselect: true,
          render: SongRender
        }]
      }]
    }
  ]);
}