var weapon_checked = {};
var collab_checked = {};
var hide_type = "hide";

function to_display(element) {
  let classes = Array.from(element.classList);
  switch (hide_type) {
    case "hide":
      return classes.every(classname => !(weapon_checked[classname] || collab_checked[classname]));
    case "union":
      return !classes.every(classname => !(weapon_checked[classname] || collab_checked[classname]));
    case "intersection":
      return Object.keys(weapon_checked).every(key => {
        if (weapon_checked[key]) return classes.includes(key);
        else return true;
      }) && Object.keys(collab_checked).every(key => {
        if (collab_checked[key]) return classes.includes(key);
        else return true;
      });
    default:
      break;
  }
}

function refresh() {
  let list = document.getElementById("combos").children;
  for (let collab of list) {
    if (to_display(collab)) {
      collab.style.display = "block";
    }
    else {
      collab.style.display = "none";
    }
  }
}

function filter_weapons(name) {
  weapon_checked[name] ^= true;
  refresh();
}

function filter_collabs(name) {
  collab_checked[name] ^= true;
  refresh();
}

function invert_weapons() {
  Object.keys(weapon_checked).forEach(key => weapon_checked[key] ^= true);
  for (let input of document.getElementsByClassName("weapon-hide")) {
    input.checked ^= true;
  }
  refresh();
}

function invert_collabs() {
  Object.keys(collab_checked).forEach(key => collab_checked[key] ^= true);
  for (let input of document.getElementsByClassName("collab-hide")) {
    input.checked ^= true;
  }
  refresh();
}

document.addEventListener('DOMContentLoaded', () => {
  for (let input of document.getElementsByClassName("weapon-hide")) {
    weapon_checked[input.getAttribute('NAME')] = false;
  }
  for (let input of document.getElementsByClassName("collab-hide")) {
    collab_checked[input.getAttribute('NAME')] = false;
  }
});

function show_type(type) {
  hide_type = type;
  refresh();
}

function reset() {
  Object.keys(weapon_checked).forEach(key => weapon_checked[key] = false);
  for (let input of document.getElementsByClassName("weapon-hide")) {
    input.checked = false;
  }
  Object.keys(collab_checked).forEach(key => collab_checked[key] = false);
  for (let input of document.getElementsByClassName("collab-hide")) {
    input.checked = false;
  }
  refresh();
}
