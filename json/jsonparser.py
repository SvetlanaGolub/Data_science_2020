import json
from itertools import chain
import csv

file = open('FrequentFlyerForum-Profiles.json', 'r')
csv_file = open('ForumProfiles.csv', 'w')
writer = csv.writer(csv_file, delimiter=',')
a = json.load(file)
a1 = a['Forum Profiles']
for profile in a1: 
    one_object = list()
    one_object.append(profile['Real Name']['First Name'])
    one_object.append(profile['Real Name']['Last Name']) 
    one_object.append(profile['NickName']) 
    one_object.append(profile['Sex'])
    t = profile['Travel Documents'][0]['Passports']
    if t is None:
        one_object.append('')
    flights = profile['Registered Flights']
    lists = list()
    for flight in flights:
        inserted_list = list()
        inserted_list.append(flight['Date'])
        inserted_list.append(flight['Codeshare'])
        inserted_list.append(flight['Arrival']['City'])
        inserted_list.append(flight['Arrival']['Airport'])
        inserted_list.append(flight['Arrival']['Country'])
        inserted_list.append(flight['Flight'])
        inserted_list.append(flight['Departure']['City'])
        inserted_list.append(flight['Departure']['Airport'])
        inserted_list.append(flight['Departure']['Country'])
        lists.append(inserted_list)
    cross_list = list()
    for obj in lists:
        cross_list.append(list(chain(one_object, obj)))
    loyality = profile['Loyality Programm']
    programs = list()
    for loys in loyality:
        ins_list = list()
        ins_list.append(loys['Status'])
        ins_list.append(loys['programm'])
        ins_list.append(loys['Number'])
        programs.append(ins_list)
    for el in cross_list:
        for elem in programs:
            ins = list(chain(el,elem))
            writer.writerow(ins)
file.close()
csv_file.close()
