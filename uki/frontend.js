(function() {
// define namespace
frontend = {};

// all core modules
include('frameworks/uki/uki-core.js');
include('frameworks/uki/uki-data/ajax.js');

// used views, comment out unused ones
include('frameworks/uki/uki-view/view/box.js');
include('frameworks/uki/uki-view/view/image.js');
include('frameworks/uki/uki-view/view/button.js');
include('frameworks/uki/uki-view/view/checkbox.js');
include('frameworks/uki/uki-view/view/radio.js');
include('frameworks/uki/uki-view/view/textField.js');
include('frameworks/uki/uki-view/view/label.js');
include('frameworks/uki/uki-view/view/list.js');
include('frameworks/uki/uki-view/view/table.js');
include('frameworks/uki/uki-view/view/slider.js');
include('frameworks/uki/uki-view/view/splitPane.js');
include('frameworks/uki/uki-view/view/scrollPane.js');
include('frameworks/uki/uki-view/view/popup.js');
include('frameworks/uki/uki-view/view/flow.js');
include('frameworks/uki/uki-view/view/toolbar.js');

// theme
include('frameworks/uki/uki-theme/airport.js');

// data
include('frameworks/uki/uki-data/model.js');
include('frontend/layout/main.js');

uki.theme.airport.imagePath = 'i/';

// skip interface creation if we're testing
if (window.TESTING) return;

frontend.layout.main().attachTo(window, '960 640');

function updateState(d) {
  console.log(d.filters, d);
  uki('#libraries').data(d.libraries);
  uki('#artists').data(d.artists);
  uki('#albums').data(d.albums);
  uki('#playlist').data(d.songs);

  for (var filter in d.filters) {
    var selectedRows = d.filters[filter];
    var list = uki("#" + filter);

    if (!selectedRows) {
      list.selectedIndexes([]);
      continue;
    }

    var rows = list.data();
    var selectedIndexes = []
    for (var i = 0; i < selectedRows.length; i++)
      selectedIndexes.push(rows.indexOf(selectedRows[i]));
    list.selectedIndexes(selectedIndexes);
  }
};

uki.getJSON('/state', {}, updateState);

function onLibraryChange(e) {
  uki('#artists').selectedIndexes([]);
  uki('#albums').selectedIndexes([]);
  return onStateChange(e);
}

function onArtistChange(e) {
  uki('#albums').selectedIndexes([]);
  return onStateChange(e);
}

function onStateChange(e) {
  var data = {
    'libraries': uki('#libraries').selectedRows().length > 0 ? uki('#libraries').selectedRows() : 'nil', // uki.post isn't sending empty arrays
    'artists':   uki('#artists').selectedRows().length > 0 ? uki('#artists').selectedRows() : 'nil',
    'albums':    uki('#albums').selectedRows().length > 0 ? uki('#albums').selectedRows() : 'nil',
    '_method':   'put'
  }
  console.log(data);
  uki.post('/state', data, updateState, 'json');
}

uki('#libraries').bind('click', onLibraryChange);
uki('#artists').bind('click', onArtistChange);
uki('#albums').bind('click', onStateChange);

})();
