# encoding: utf-8
require "rubygems"
require "mechanize"

a = Mechanize.new

LINE_ID = 16531
LINK = "http://betcityru.com/bets/bets2.php?line_id[]=#{LINE_ID}"

SPLIT_FOR_LEAGUE_AND_EVENT = ". " # разделитель
ID_RESULT = "line"

FIELDS = %w{ TIME TEAM_1 HANDICAP_1 ODDS_1 TEAM_2 HANDICAP_2 ODDS_2 1 X 2 1X 12 X2 TOTAL UNDER OVER }

a.get(LINK) do |page|

  league_and_event = page.search('thead b').inner_text # имя лиги и события

  unless league_and_event.empty?

    league_and_event_array = league_and_event.split(SPLIT_FOR_LEAGUE_AND_EVENT) # разбиваем строку на массив
    league = league_and_event_array.first # первый элемент массива - имя лиги
    event = league_and_event_array.drop(1).join(SPLIT_FOR_LEAGUE_AND_EVENT) # остальные элементы, кроме первого - имя события

    puts "Имя лиги: #{league}"
    puts "Имя события: #{event}"
    puts "###"

    # ---

    # события
    dates = page.search(".date").each do |date|

      date_event = Date.parse(date.search("td").inner_text) # преобразование строки в дату
      puts "Дата мероприятия: #{date_event.strftime("%d %B %Y")}"

      column_names_element = date.next_element # tbody.chead - наименования столбцов
      column_names = column_names_element.search("td") # массив наименований
      # вывод названий необходимых столбцов
      # можно и по одному прописать - column_names[FIELDS.index('TIME')]
      FIELDS.each_with_index do |field, index|
        print column_names[index].inner_text + " | "
      end
      print "\n"

      line_result = column_names_element.next_element # tbody#line - результаты

      # перебор всех результатов данной даты
      while line_result && line_result.attribute("id").to_s == ID_RESULT do
        results = line_result.search("tr").first.search("td")

        # вывод результатов необходимых столбцов
        # можно и по одному прописать - results[FIELDS.index('TIME')]
        FIELDS.each_with_index do |field, index|
          print results[index].inner_text + " | "
        end
        print "\n"

        line_result = line_result.next_element # переход к следующему элементу
     end

      puts "---"

    end
  else
    puts "На странице #{LINK} нет информации о событиях"
  end

end