#!/usr/bin/env ruby
# frozen-string-literal: true

require 'set'
require 'json'

ITEM_NAMES = Set.new [
  'Spider Cooking',
  'Elite Lava Bucket',
  'CEO\'s Tears',
  'Wamy Water',
  'Holo Bomb',
  'Psycho Axe',
  'BL Book',
  'Cutting Board',
  'Fan Beam',
  'Plug Type Asacoco',
  'Glowstick',
  'X-Potato',
  'Idol Song'
]

def name_to_class(name)
  name.delete(" '")
end

class Collab
  attr_reader :ingredients, :name

  def initialize(collab_name, ingredients)
    ingredients.each { |weapon| abort "Unknown weapon: #{weapon}" unless ITEM_NAMES.include? weapon }
    @name = collab_name
    @ingredients = ingredients
  end

  def to_json(arg)
    { name: @name, ingredients: @ingredients }.to_json(arg)
  end

  def class_list
    @ingredients.map { |weapon| name_to_class(weapon) } + [name_to_class(@name)]
  end
end

collabs = [
  ['Breathe-In Type Asacoco', ['Holo Bomb', 'Plug Type Asacoco']],
  ['Dragon Fire', ['Fan Beam', 'Plug Type Asacoco']],
  ['Elite Cooking', ['Elite Lava Bucket', 'Spider Cooking']],
  ['Idol Concert', ['Glowstick', 'Idol Song']],
  ['BL Fujoshi', ['BL Book', 'Psycho Axe']],
  ['MiComet', ['Elite Lava Bucket', 'Psycho Axe']],
  ['Flattening Board', ['Holo Bomb', 'Cutting Board']],
  ['Light Beam', ['Glowstick', 'Fan Beam']],
  ['Broken Dreams', ['Spider Cooking', 'CEO\'s Tears']],
  ['Frozen Sea', ['BL Book', 'Wamy Water']],
  ['Stream of Tears', ['Fan Beam', 'CEO\'s Tears']],
  ['Rap Dog', ['X-Potato', 'Idol Song']]
].sort { |a, b| a[0] <=> b[0] }.map { |collab_name, igredients| Collab.new(collab_name, igredients) }

# Due to 5 weapon slots, there can be only 4 collabs, so (collabs.size choose 4) theoretical options
possible_combos = []
collabs.combination(4) do |combination|
  used_weapons = Set.new
  overlap = false
  combination.each do |collab|
    collab.ingredients.each do |weapon|
      if used_weapons.include?(weapon)
        overlap = true
        break
      else
        used_weapons.add(weapon)
      end
    end
  end
  possible_combos.append(combination) unless overlap
end

def combo_to_html(combo)
  <<~HTML
    <li class="#{combo.map(&:class_list).flatten.join(' ')}">
      <ul>
        #{
          combo.map do |collab|
            <<~HTML
              <li>
                <div class="#{name_to_class(collab.name)} icon"><!--#{collab.name}--></div>
              </li>
            HTML
          end.join("\n")
        }
      </ul>
    </li>
  HTML
end

html_content = <<~HTML
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <title>Holocure 4-item combos</title>
    <script src="../js/holocure.js"></script>
    <link rel="stylesheet" href="../css/holocure.css">
  </head>
  <body>
    <section id="filters">
      <input type="radio" id="hide-checked" name="hide-show" onclick="show_type('hide')" checked="true"><label for="hide-checked">Hide combos using any checked items</label>
      <br />
      <input type="radio" id="show-union-checked" name="hide-show" onclick="show_type('union')"><label for="show-union-checked">Show combos using at least one checked item</label>
      <br />
      <input type="radio" id="show-intersection-checked" name="hide-show" onclick="show_type('intersection')"><label for="show-intersection-checked">Show combos using all of checked items</label>
      <div id="filter_checkboxes">
        <div>
          #{
            ITEM_NAMES.to_a.sort.map do |weapon|
              name = name_to_class(weapon)
              <<~HTML
                <div>
                  <input class="weapon-hide" type="checkbox\" name="#{name}" onclick="filter_weapons('#{name}')">
                  <label for="#{name}" class="icon #{name}">#{weapon}</label>
                </div>
              HTML
            end.join("\n")
          }
          <input type="button" value="Invert selection" onclick="invert_weapons()">
        </div>
        <div>
          #{
            collabs.map do |collab|
              name = name_to_class(collab.name)
              <<~HTML
                <div>
                  <input type="checkbox" name="#{name}" class="collab-hide" onclick="filter_collabs('#{name}')">
                  <label for="#{name}" class="icon #{name}">#{collab.name} (#{collab.ingredients.join(' + ')})</label>
                </div>
              HTML
            end.join("\n")
          }
          <input type="button" value="Invert selection" onclick="invert_collabs()">
        </div>
        <input type="button" value="Reset" onclick="reset()" id="reset-button">
      </div>
    </section>
    <ul id="combos">
      #{
        possible_combos.map do |combo|
          combo_to_html(combo)
        end.join("\n")
      }
    </ul>
  </body>
  </html>
HTML

File.write("#{__dir__}/../docs/holocure.html", html_content)
