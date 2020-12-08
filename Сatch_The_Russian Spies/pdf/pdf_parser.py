import tabula
import csv

file = 'Skyteam_Timetable.pdf'

# Задаём размеры областей с таблицами
box1 = [0, 0, 29, 10]
box2 = [0, 11, 29, 26]

fc = 28.28
# Умножаем сантиметры на коэффициент
for n in range(len(box1)):
    box1[n] *= fc
    box2[n] *= fc

# Делим на блоки, чтобы записывать в cvs по частям
blocks_number = 30
blocks_size = 917

prev_addr = [["Miss", "Miss"], ["Miss", "Miss"]]
columns = ['Validity', 'Days', 'Departure', 'Arrival', 'Flight', 'Aircraft', 'Travel_time']


# Извлечение данных из json и помещение их в список слварей
def to_list(which_box, json_table, index, from_ad, to_ad):
    from_country = from_ad[:from_address.find(',')].strip()
    from_city = from_ad[from_address.find(',') + 1:].strip()
    # print(from_country, from_city)
    to_country = to_ad[:to_address.find(',')].strip()
    to_city = to_ad[to_address.find(',') + 1:].strip()

    for i in range(index, len(json_table[which_box]['data'])):
        column_notations = {'FromCountry': from_country,
                            'FromCity': from_city, 'ToCountry': to_country, 'ToCity': to_city}
        for j in range(len(json_table[which_box]['data'][i])):
            column_notations[columns[j]] = json_table[which_box]['data'][i][j]['text']
        full_table.append(column_notations)


# Преобразование получившегося списка в формат csv
def to_csv(tables):
    column_names = tables[0].keys()
    with open('test.csv', 'a') as output_file:
        dict_writer = csv.DictWriter(output_file, column_names)
        dict_writer.writeheader()
        dict_writer.writerows(tables)


for block in range(0, blocks_number):
    print("Block number: ", block)
    full_table = []
    for page in range(31 + blocks_size * block, 5 + blocks_size * (block + 1)):
        # print('Page:', page)
        table = tabula.read_pdf(file, pages=page, area=[box1, box2], output_format='json', stream=True, lattice=True)
        # Если не удалось получить информацию, работаем со следующей таблицей
        if len(table) == 0:
            continue
        # print(table[0]['data'])

        for box in range(2):
            # Если таблица пустая, работаем со следующей
            if len(table[box]['data']) < 3:
                continue
            # Пропускаем строки, в которых написаны перевозчики
            table[box]['data'] = [item for item in table[box]['data'] if not item[0]['text'].startswith('Operated')]
            # Если в первой строке адрес вылета и прилёта, записываем
            if table[box]['data'][0][3]['text'] == '':
                if table[box]['data'][3][0]['text'] == 'Consult your travel agent for details':
                    continue
                from_address = table[box]['data'][0][1]['text']
                to_address = table[box]['data'][1][1]['text']
                prev_addr[box] = [from_address, to_address]
                from_index = 3
            # Если с первой строки продолжается предидущая таблица, берём предидущий адрес
            else:
                from_address = prev_addr[box][0]
                to_address = prev_addr[box][1]
                from_index = 0

            to_list(box, table, from_index, from_address, to_address)

    to_csv(full_table)
