﻿
Перем ТаблицаЗачетаНДС;
Перем ПорядокУплатыНДС;

////////////////////////////////////////////////////////////////////////////////

Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	Возврат Новый Структура("ПриемныйАкт,РасчетСтоимостиНоменклатуры","Приходный акт","Расчет стоимости номенклатуры");
КонецФункции

Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	Если ИмяМакета="ПриемныйАкт" Тогда
		ТабДокумент = ПечатьПриемныйАкт();
	ИначеЕсли ИмяМакета="РасчетСтоимостиНоменклатуры" Тогда
		ТабДокумент = ПечатьРасчетаСтоимостиНоменклатуры();
	КонецЕсли; 
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, "Расчет стоимости");
КонецПроцедуры

Функция ПечатьПриемныйАкт()
	ТабДок = Новый ТабличныйДокумент;
	
	Макет = ПолучитьМакет("ПриемныйАкт");
	
	Руководители = ОтветственныеЛица(Организация, Дата);	
	
	Область = Макет.ПолучитьОбласть("Шапка");
	Область.Параметры.Организация = Организация;
	Область.Параметры.Номер = ПолучитьНомерНаПечать(ЭтотОбъект);
	Область.Параметры.Дата = Формат(Дата,"ДЛФ=DD");
	Область.Параметры.ПриходныйДокумент = ПриходныйДокумент;
	Область.Параметры.Доверенность = "№ "+ПолучитьНомерНаПечать(Доверенность.Ссылка)+" от "+формат(Доверенность.Дата,"ДФ=dd.MM.yyyy");
	Область.Параметры.Через = ФИОСотрудника(Доверенность.Сотрудник,Дата);
	Область.Параметры.Поставщик = Поставщик;
	Область.Параметры.ДоговорПоставщика = ДоговорПоставщика;
	ТабДок.Вывести(Область);
	
	Область = Макет.ПолучитьОбласть("ШапкаТаблицы");
	ТабДок.Вывести(Область);
	
	Область = Макет.ПолучитьОбласть("Строка");
	ОбластьИтого = Макет.ПолучитьОбласть("Итог");
	
	Запрос=новый Запрос;
	Запрос.Текст=
	"ВЫБРАТЬ
	|	ПоступлениеНоменклатурыНоменклатура.Номенклатура,
	|	ПоступлениеНоменклатурыНоменклатура.Количество,
	|	ПоступлениеНоменклатурыНоменклатура.Сумма КАК Сумма,
	|	ПоступлениеНоменклатурыНоменклатура.СтавкаНДС,
	|	ПоступлениеНоменклатурыНоменклатура.СуммаНДС КАК СуммаНДС,
	|	ПоступлениеНоменклатурыНоменклатура.СчетУчетаБУ,
	|	ПоступлениеНоменклатурыНоменклатура.Цена,
	|	ПоступлениеНоменклатурыНоменклатура.Сумма + ПоступлениеНоменклатурыНоменклатура.СуммаНДС КАК Всего,
	|	ПоступлениеНоменклатурыНоменклатура.НомерСтроки КАК НомерСтроки,
	|	ПоступлениеНоменклатурыНоменклатура.Номенклатура.БазоваяЕдиницаИзмерения КАК ЕдиницаИзмерения
	|ИЗ
	|	Документ.ПоступлениеНоменклатурыПродаж.Номенклатура КАК ПоступлениеНоменклатурыНоменклатура
	|ГДЕ
	|	ПоступлениеНоменклатурыНоменклатура.Ссылка = &Ссылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтроки
	|ИТОГИ
	|	СУММА(Сумма),
	|	СУММА(СуммаНДС),
	|	СУММА(Всего)
	|ПО
	|	ОБЩИЕ";
	
	Запрос.УстановитьПараметр("Ссылка",Ссылка);
	ВыборкаОбщие=Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	ВыборкаОбщие.Следующий();
	ОбластьИтого.Параметры.Заполнить(ВыборкаОбщие);	
	ОбластьИтого.Параметры.Завскладом=ДанныеФизЛица(Организация,Склад.МОЛ.ФизическоеЛицо,Дата).Представление;
	Выборка=ВыборкаОбщие.Выбрать();
	Пока Выборка.Следующий() Цикл
		Область.Параметры.Заполнить(Выборка);
		ТабДок.Вывести(Область);
	КонецЦикла; 
	
	ТабДок.Вывести(ОбластьИтого);
	
	ТабДок.ФиксацияСверху=0;
	ТабДок.ФиксацияСлева=0;
	ТабДок.ЭкземпляровНаСтранице=0;
	ТабДок.ТолькоПросмотр = Истина;
	ТабДок.АвтоМасштаб = Истина;
	ТабДок.ОриентацияСтраницы = ОриентацияСтраницы.Портрет;
	
	Возврат ТабДок;
КонецФункции

Функция ПечатьРасчетаСтоимостиНоменклатуры()
	
	ТабДок = Новый ТабличныйДокумент;
	
	Макет = ПолучитьМакет("РасчетСтоимости");
	
	Руководители = ОтветственныеЛица(Организация, Дата);	
	
	Область = Макет.ПолучитьОбласть("Шапка");
	Область.Параметры.Организация = Организация;
	Область.Параметры.Склад = Склад;
	Область.Параметры.Номер = ПолучитьНомерНаПечать(ЭтотОбъект);
	Область.Параметры.Дата = Формат(Дата,"ДЛФ=DD");
	Область.Параметры.Поставщик = Поставщик;
	Область.Параметры.ДоговорПоставщика	= ДоговорПоставщика;
	Область.Параметры.ПриходныйДокумент = ПриходныйДокумент;
	ТабДок.Вывести(Область);
	
	
	ОбластьНачало = Макет.ПолучитьОбласть("ШапкаТаблицы|Начало");
	ОбластьДопРасход = Макет.ПолучитьОбласть("ШапкаТаблицы|ДопРасход");
	ОбластьИтог= Макет.ПолучитьОбласть("ШапкаТаблицы|ВертИтог");
	
	ТабДок.Вывести(ОбластьНачало);
	ИмяСекции="Доп. расходы";
	Для Каждого Строка из РасходыВключаемыеВСтоимость Цикл
		ОбластьДопРасход.Параметры.ИмяСекции=ИмяСекции;
		ОбластьДопРасход.Параметры.Описание=Строка.Описание;
		ТабДок.Присоединить(ОбластьДопРасход);
		ИмяСекции="";
	КонецЦикла;	
	ТабДок.Присоединить(ОбластьИтог);
	
	НомерСтроки=0;
	ОбластьНачало = Макет.ПолучитьОбласть("Строка|Начало");
	ОбластьДопРасход = Макет.ПолучитьОбласть("Строка|ДопРасход");
	ОбластьИтог= Макет.ПолучитьОбласть("Строка|ВертИтог");
	
	ТаблицаНоменклатура=СформироватьТаблицуНоменклатуры();
	
	Для каждого СтрокаНоменклатуры Из ТаблицаНоменклатура  Цикл
		НомерСтроки=НомерСтроки+1;
		ОбластьНачало.Параметры.НомерСтроки = НомерСтроки;
		ОбластьНачало.Параметры.ЕдиницаИзмерения = СтрокаНоменклатуры.Номенклатура.БазоваяЕдиницаИзмерения;
		ОбластьНачало.Параметры.Заполнить(СтрокаНоменклатуры);
		ТабДок.Вывести(ОбластьНачало);
		
		СуммаДопРасходов=0;
		Для Каждого Строка из РасходыВключаемыеВСтоимость Цикл
			ОбластьДопРасход.Параметры.Сумма=СтрокаНоменклатуры["РасходыВключаемыеВСтоимость"+Строка(Строка.НомерСтроки)];
			СуммаДопРасходов=СуммаДопРасходов+СтрокаНоменклатуры["РасходыВключаемыеВСтоимость"+Строка(Строка.НомерСтроки)];
			ТабДок.Присоединить(ОбластьДопРасход);
		КонецЦикла;	
		ОбластьИтог.Параметры.СуммаДопРасходов=СуммаДопРасходов;
		ОбластьИтог.Параметры.ОбщаяСумма=СтрокаНоменклатуры.Сумма+СуммаДопРасходов;
		Цена=0;
		Если СтрокаНоменклатуры.Количество<>0 Тогда
			Цена=Окр((СтрокаНоменклатуры.Сумма+СуммаДопРасходов)/СтрокаНоменклатуры.Количество,2);
		Иначе
			Цена=СтрокаНоменклатуры.Сумма+СуммаДопРасходов;
		КонецЕсли;	
		ОбластьИтог.Параметры.ЦенаЕдиницы=Цена;
		ТабДок.Присоединить(ОбластьИтог);
	КонецЦикла; 
	
	//Итоги ===========================
	
	ОбластьНачало = Макет.ПолучитьОбласть("Итог|Начало");
	ОбластьДопРасход = Макет.ПолучитьОбласть("Итог|ДопРасход");
	ОбластьИтог= Макет.ПолучитьОбласть("Итог|ВертИтог");
	
	ОбластьНачало.Параметры.Сумма=Номенклатура.Итог("Сумма");
	ОбластьНачало.Параметры.Ответственный=Ответственный;
	
	ОбластьНачало.Параметры.СуммаНДС=Номенклатура.Итог("СуммаНДС")+РасходыВключаемыеВСтоимость.Итог("СуммаНДС");
	ОбластьНачало.Параметры.Всего=Номенклатура.Итог("Сумма")+РасходыВключаемыеВСтоимость.Итог("Сумма")+Номенклатура.Итог("СуммаНДС")+РасходыВключаемыеВСтоимость.Итог("СуммаНДС");
	
	ТабДок.Вывести(ОбластьНачало);
	
	СуммаДопРасходов=0;
	Для Каждого Строка из РасходыВключаемыеВСтоимость Цикл
		ОбластьДопРасход.Параметры.Сумма=ТаблицаНоменклатура.Итог("РасходыВключаемыеВСтоимость"+Строка(Строка.НомерСтроки));
		СуммаДопРасходов=СуммаДопРасходов+ТаблицаНоменклатура.Итог("РасходыВключаемыеВСтоимость"+Строка(Строка.НомерСтроки));
		ТабДок.Присоединить(ОбластьДопРасход);
	КонецЦикла;	
	ОбластьИтог.Параметры.СуммаДопРасходов=СуммаДопРасходов;
	ОбластьИтог.Параметры.ОбщаяСумма=Номенклатура.Итог("Сумма")+СуммаДопРасходов;
	
	ТабДок.Присоединить(ОбластьИтог);
	
	
	ТабДок.ФиксацияСверху=9;
	ТабДок.ФиксацияСлева=0;
	ТабДок.ЭкземпляровНаСтранице=1;
	ТабДок.ТолькоПросмотр = Истина;
	
	Возврат ТабДок;
КонецФункции

////////////////////////////////////////////////////////////////////////////////

Процедура ЗаписатьЦеныВСправочник()
	Если ЗаписыватьЦеныВСправочник Тогда
		ТаблицаНоменклатуры=СформироватьТаблицуНоменклатуры();	
		Для Каждого Строка из ТаблицаНоменклатуры Цикл
			НоменклатураОбъект=Строка.Номенклатура.ПолучитьОбъект();
			Цена=0;
			Если Строка.Количество<>0 Тогда
				Цена=(Строка.Сумма+Строка.РасходыВключаемыеВСтоимость)/Строка.Количество;
			КонецЕсли;	
			НоменклатураОбъект.Цена=Цена;
			НоменклатураОбъект.Записать();
		КонецЦикла;	
	КонецЕсли;
КонецПроцедуры

Функция СформироватьТаблицуНоменклатуры()
	ТаблицаНоменклатуры=Номенклатура.Выгрузить();
	ТаблицаНоменклатуры.Колонки.Добавить("РасходыВключаемыеВСтоимость",Новый ОписаниеТипов("Число",Новый КвалификаторыЧисла(18,2)));
	Для Каждого Строка из РасходыВключаемыеВСтоимость Цикл
		ТаблицаНоменклатуры.Колонки.Добавить("РасходыВключаемыеВСтоимость"+Строка(Строка.НомерСтроки),Новый ОписаниеТипов("Число",Новый КвалификаторыЧисла(18,2)));
	КонецЦикла;	
	Если ТаблицаНоменклатуры.Итог("Сумма")<>0 Тогда
		Для Каждого Строка из РасходыВключаемыеВСтоимость Цикл
			СуммаКРаспределению=Строка.Сумма;
			Остаток=СуммаКРаспределению;
			Для Каждого СтрокаТаблицаНоменклатуры из ТаблицаНоменклатуры Цикл
				Сумма=Окр(СуммаКРаспределению*СтрокаТаблицаНоменклатуры.Сумма/ТаблицаНоменклатуры.Итог("Сумма"),2);
				СтрокаТаблицаНоменклатуры["РасходыВключаемыеВСтоимость"+Строка(Строка.НомерСтроки)]=СтрокаТаблицаНоменклатуры["РасходыВключаемыеВСтоимость"+Строка(Строка.НомерСтроки)]+Сумма;
				СтрокаТаблицаНоменклатуры["РасходыВключаемыеВСтоимость"]=СтрокаТаблицаНоменклатуры["РасходыВключаемыеВСтоимость"]+Сумма;
				Остаток=Остаток-Сумма;
			КонецЦикла;	
			Если Остаток<>0 Тогда
				ТаблицаНоменклатуры[0]["РасходыВключаемыеВСтоимость"+Строка(Строка.НомерСтроки)]=ТаблицаНоменклатуры[0]["РасходыВключаемыеВСтоимость"+Строка(Строка.НомерСтроки)]+Остаток;	
				ТаблицаНоменклатуры[0]["РасходыВключаемыеВСтоимость"]=ТаблицаНоменклатуры[0]["РасходыВключаемыеВСтоимость"]+Остаток;	
			КонецЕсли;	
		КонецЦикла;	
	КонецЕсли;
	Возврат ТаблицаНоменклатуры;
КонецФункции	

Функция СформироватьОписаниеПервичногоДокумента(ПервичныйДокумент)
	ПервичныйДокументСтр=сокрлп(ПервичныйДокумент);	
	Если лев(ПервичныйДокументСтр,1)="№" или ЭтоЦифра(лев(ПервичныйДокументСтр,1)) Тогда
		Возврат "Сч.фак. "+ПервичныйДокументСтр;	
	Иначе
		Возврат ПервичныйДокументСтр;
	КонецЕсли; 
КонецФункции

Процедура ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента)
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	СтруктураОбязательныхПолей.Вставить("Склад","Не выбран склад.");
	СтруктураОбязательныхПолей.Вставить("Поставщик","Не выбран поставщик.");
	СтруктураОбязательныхПолей.Вставить("ДоговорПоставщика","Не указан договор с поставщиком.");
	СтруктураОбязательныхПолей.Вставить("СчетУчетаРасчетовСКонтрагентом","Не указан счет учета расчетов с поставщиком.");
	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	//Проверяем заполнение табличной части 
	СтруктураПолей = Новый Структура();
	СтруктураПолей.Вставить("Номенклатура","Не выбрана номенклатура");
	СтруктураПолей.Вставить("СчетУчетаБУ","Не указан счет учета номенклатуры (таблица ""Номенклатура"")");
	ПроверитьЗаполнениеТабличнойЧастиПлатежногоДокумента(ЭтотОбъект, "Номенклатура", СтруктураПолей, Отказ, Заголовок);
	//Проверяем заполнение табличной части 
	СтруктураПолей = Новый Структура();
	СтруктураПолей.Вставить("СчетКредит","Не указан счет кредита (таблица ""Дополнительные расходы"")");
	ПроверитьЗаполнениеТабличнойЧастиПлатежногоДокумента(ЭтотОбъект, "РасходыВключаемыеВСтоимость", СтруктураПолей, Отказ, Заголовок);
	//Проверяем заполнение табличной части 
	СтруктураПолей = Новый Структура();
	СтруктураПолей.Вставить("СчетДебет","Не указан счет дебет (таблица ""Прочее"")");
	СтруктураПолей.Вставить("СчетКредит","Не указан счет кредит (таблица ""Прочее"")");
	ПроверитьЗаполнениеТабличнойЧастиПлатежногоДокумента(ЭтотОбъект, "Прочее", СтруктураПолей, Отказ, Заголовок);
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	СуммаПоДокументу = Номенклатура.Итог("Сумма")+Номенклатура.Итог("СуммаНДС");
	СуммаПоДокументу = СуммаПоДокументу+Прочее.Итог("Сумма")+Прочее.Итог("СуммаНДС");
	//
	Если ПоступлениеВРозницу Тогда
		Для Каждого Строка Из Номенклатура Цикл
			Строка.СчетУчетаБУ=ПланыСчетов.Хозрасчетный.НайтиПоКоду("2920");
		КонецЦикла;	
	КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента);
	ЗаписатьЦеныВСправочник();
	Если Не Отказ Тогда
		ДвиженияПоБУ(Режим, Отказ, Заголовок, СтруктураШапкиДокумента);
	КонецЕсли;
КонецПроцедуры

Процедура ДвиженияПоБУ(Режим, Отказ, Заголовок ,СтруктураШапкиДокумента)
	ПорядокУплатыНДС = ПолучитьПорядокУплатыНДС(Дата,Организация);
	Счет2980 = ПланыСчетов.Хозрасчетный.НайтиПоКоду("2980");
	ТаблицаЗачетаНДС = СоздатьТаблицуДляУчетаНДС();
	ПроводкиБУ = Движения.Хозрасчетный;
	
	Для Каждого СтрокаНоменклатуры Из Номенклатура Цикл
		Если НаКомиссию Тогда 
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание	 = "Поступление номенклатуры на комиссию";     
			Проводка.ПервичныйДокумент=СформироватьОписаниеПервичногоДокумента(ПриходныйДокумент);     
			//
			Проводка.СчетДт = ПланыСчетов.Хозрасчетный.А004;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаНоменклатуры.Номенклатура);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,Склад);
            УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,Поставщик);
            Проводка.КоличествоДт=СтрокаНоменклатуры.Количество;
			Проводка.Сумма = СтрокаНоменклатуры.Сумма;
		Иначе
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание	 = "Поступление номенклатуры на склад";     
			Проводка.ПервичныйДокумент=СформироватьОписаниеПервичногоДокумента(ПриходныйДокумент);     
			//
			Проводка.СчетДт = СтрокаНоменклатуры.СчетУчетаБУ;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаНоменклатуры.Номенклатура);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,Склад);
			Проводка.КоличествоДт = СтрокаНоменклатуры.Количество;
			//
			Проводка.СчетКт = СчетУчетаРасчетовСКонтрагентом;
			Если ЭтоСчетСАналитикойПоКонтрагентамИДоговорам(СчетУчетаРасчетовСКонтрагентом) Тогда
				УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,Поставщик);
				УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,ДоговорПоставщика);
			Иначе
				УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,Субконто1);
				УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,Субконто2);
				УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,3,Субконто3);
			КонецЕсли;
			//
			Проводка.Сумма = СтрокаНоменклатуры.Сумма; 
			////
			Если ПоступлениеВРозницу И СтрокаНоменклатуры.СуммаНаценки<>0 Тогда
				Проводка = ПроводкиБУ.Добавить();
				Проводка.Период      = Дата;
				Проводка.Организация = Организация;
				Проводка.Содержание	 = "";     
				Проводка.ПервичныйДокумент=СформироватьОписаниеПервичногоДокумента(ПриходныйДокумент);     
				//
				Проводка.СчетДт = СтрокаНоменклатуры.СчетУчетаБУ;
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаНоменклатуры.Номенклатура);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,Склад);
				//
				Проводка.СчетКт = Счет2980;
				УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокаНоменклатуры.Номенклатура);
				УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,Склад);
				Проводка.КоличествоКт = СтрокаНоменклатуры.Количество;
				//
				Проводка.Сумма = СтрокаНоменклатуры.СуммаНаценки; 
			КонецЕсли;	
			Если СтрокаНоменклатуры.СуммаНДС<>0 Тогда
				Проводка = ПроводкиБУ.Добавить();
				Проводка.Период      = Дата;
				Проводка.Организация = Организация;
				Проводка.Содержание	 = "Поступление НДС";     
				Проводка.ПервичныйДокумент = СформироватьОписаниеПервичногоДокумента(ПриходныйДокумент);     
				//
				Если ПорядокУплатыНДС = Перечисления.ПорядокУплатыНДС.Общеустановленный Тогда
					Проводка.СчетДт = СчетУчетаАвансаПлатежа("НДС");
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,"НалогиИОбязательныеПлатежи",Справочники.ПлатежиВБюджет.НДС);
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,"СтавкиНДС",СтрокаНоменклатуры.СтавкаНДС);
				Иначе
					Проводка.СчетДт = СтрокаНоменклатуры.СчетУчетаБУ;
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаНоменклатуры.Номенклатура);
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,Склад);
				КонецЕсли; 
				//
				Проводка.СчетКт = СчетУчетаРасчетовСКонтрагентом;
				Если ЭтоСчетСАналитикойПоКонтрагентамИДоговорам(СчетУчетаРасчетовСКонтрагентом) Тогда
					УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,Поставщик);
					УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,ДоговорПоставщика);
				Иначе
					УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,Субконто1);
					УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,Субконто2);
					УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,3,Субконто3);
				КонецЕсли;
				//
				Проводка.Сумма = СтрокаНоменклатуры.СуммаНДС; 
			КонецЕсли; 
			Если СтрокаНоменклатуры.СуммаСоСкидкой<>0 Тогда
				Проводка = ПроводкиБУ.Добавить();
				Проводка.Период      = Дата;
				Проводка.Организация = Организация;
				Проводка.Содержание	 = "";     
				Проводка.ПервичныйДокумент=СформироватьОписаниеПервичногоДокумента(ПриходныйДокумент);
				//
				Проводка.СчетДт = СчетУчетаРасчетовСКонтрагентом;
				Если ЭтоСчетСАналитикойПоКонтрагентамИДоговорам(СчетУчетаРасчетовСКонтрагентом) Тогда
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Поставщик);
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,ДоговорПоставщика);
				Иначе
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Субконто1);
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,Субконто2);
					УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,Субконто3);
				КонецЕсли;
				//
				Проводка.СчетКт = ПланыСчетов.Хозрасчетный.А9390;
				//
				Проводка.Сумма = СтрокаНоменклатуры.Сумма-СтрокаНоменклатуры.СуммаСоСкидкой; 
			КонецЕсли;	
			////
			Движение = ТаблицаЗачетаНДС.Добавить();
			Движение.Период				= ?(ЗначениеЗаполнено(ПриходныйДокументДата),ПриходныйДокументДата,Дата);
			Движение.Организация		= Организация;
			Движение.СчетДт				= СтрокаНоменклатуры.СчетУчетаБУ;
			Движение.Получатель			= Склад;
			Движение.СчетКт				= СчетУчетаРасчетовСКонтрагентом;
			Движение.Сумма				= СтрокаНоменклатуры.Сумма;
			Движение.СуммаНДС			= СтрокаНоменклатуры.СуммаНДС;
			Движение.Поставщик			= Поставщик;
			Движение.Договор			= ДоговорПоставщика;
			Движение.ПриходныйДокумент	= ПриходныйДокумент;
			Движение.ЗачетНДС			= ПолучитьТипЗачетаНДС(СтрокаНоменклатуры.СчетУчетаБУ);
			Движение.СтавкаНДС			= СтрокаНоменклатуры.СтавкаНДС;
			Движение.ПорядокУплатыНДС	= ПорядокУплатыНДС;
		КонецЕсли;
	КонецЦикла; 
	Для Каждого СтрокаРасходыВключаемыеВСтоимость Из РасходыВключаемыеВСтоимость Цикл
		СуммаКРаспределению=СтрокаРасходыВключаемыеВСтоимость.Сумма;
		Остаток=СуммаКРаспределению;
		СуммаНДСКРаспределению=СтрокаРасходыВключаемыеВСтоимость.СуммаНДС;
		ОстатокНДС=СуммаНДСКРаспределению;
		
		ТаблицаНоменклатуры=Номенклатура.Выгрузить();
		Для Каждого СтрокаТаблицаНоменклатуры из ТаблицаНоменклатуры Цикл
			СуммаВПроводку=Окр(СуммаКРаспределению*СтрокаТаблицаНоменклатуры.Сумма/ТаблицаНоменклатуры.Итог("Сумма"),2);
			Остаток=Остаток-СуммаВПроводку;
			СуммаНДСВПроводку=Окр(СуммаНДСКРаспределению*СтрокаТаблицаНоменклатуры.Сумма/ТаблицаНоменклатуры.Итог("Сумма"),2);
			ОстатокНДС=ОстатокНДС-СуммаНДСВПроводку;
			////
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание	 = СтрокаРасходыВключаемыеВСтоимость.Описание;     
			Проводка.ПервичныйДокумент = СформироватьОписаниеПервичногоДокумента(СтрокаРасходыВключаемыеВСтоимость.ПриходныйДокумент);     
			//
			Проводка.СчетДт = СтрокаТаблицаНоменклатуры.СчетУчетаБУ;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаТаблицаНоменклатуры.Номенклатура);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,Склад);
			//
			Проводка.СчетКт = СтрокаРасходыВключаемыеВСтоимость.СчетКредит;
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокаРасходыВключаемыеВСтоимость.Субконто1);
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,СтрокаРасходыВключаемыеВСтоимость.Субконто2);
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,3,СтрокаРасходыВключаемыеВСтоимость.Субконто3);
			//
			Проводка.Сумма = СуммаВПроводку+?(ПорядокУплатыНДС=Перечисления.ПорядокУплатыНДС.Общеустановленный,0,СуммаНДСВПроводку); 
			////
			Движение = ТаблицаЗачетаНДС.Добавить();
			Движение.Период				= ?(ЗначениеЗаполнено(СтрокаРасходыВключаемыеВСтоимость.ПриходныйДокументДата), СтрокаРасходыВключаемыеВСтоимость.ПриходныйДокументДата, Дата);
			Движение.Период				= Дата;
			Движение.Организация		= Организация;
			Движение.СчетДт				= СтрокаТаблицаНоменклатуры.СчетУчетаБУ;
			Движение.Получатель			= Склад;
			Движение.СчетКт				= СтрокаРасходыВключаемыеВСтоимость.СчетКредит;
			Движение.Сумма				= СуммаВПроводку;
			Движение.СуммаНДСПоУслугам	= СуммаНДСВПроводку;
			Движение.Поставщик			= СтрокаРасходыВключаемыеВСтоимость.Субконто1;
			Движение.Договор			= СтрокаРасходыВключаемыеВСтоимость.Субконто2;
			Движение.ПриходныйДокумент	= СтрокаРасходыВключаемыеВСтоимость.ПриходныйДокумент;
			Движение.ЗачетНДС			= ПолучитьТипЗачетаНДС(СтрокаТаблицаНоменклатуры.СчетУчетаБУ,истина);
			Движение.СтавкаНДС			= СтрокаРасходыВключаемыеВСтоимость.СтавкаНДС;
			Движение.ПорядокУплатыНДС	= ПорядокУплатыНДС;
		КонецЦикла;
		Если Остаток+?(ПорядокУплатыНДС=Перечисления.ПорядокУплатыНДС.Общеустановленный,0,ОстатокНДС)<>0 Тогда
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание	 = СтрокаРасходыВключаемыеВСтоимость.Описание;     
			Проводка.ПервичныйДокумент = СформироватьОписаниеПервичногоДокумента(СтрокаРасходыВключаемыеВСтоимость.ПриходныйДокумент);     
			//
			Проводка.СчетДт = ТаблицаНоменклатуры[0].СчетУчетаБУ;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,ТаблицаНоменклатуры[0].Номенклатура);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,Склад);
			//
			Проводка.СчетКт = СтрокаРасходыВключаемыеВСтоимость.СчетКредит;
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокаРасходыВключаемыеВСтоимость.Субконто1);
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,СтрокаРасходыВключаемыеВСтоимость.Субконто2);
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,3,СтрокаРасходыВключаемыеВСтоимость.Субконто3);
			//
			Проводка.Сумма = Остаток+?(ПорядокУплатыНДС=Перечисления.ПорядокУплатыНДС.Общеустановленный,0,ОстатокНДС); 
		КонецЕсли;
		Если Остаток<>0 ИЛИ ОстатокНДС<>0 Тогда
			Движение = ТаблицаЗачетаНДС.Добавить();
			Движение.Период				= ?(ЗначениеЗаполнено(СтрокаРасходыВключаемыеВСтоимость.ПриходныйДокументДата),СтрокаРасходыВключаемыеВСтоимость.ПриходныйДокументДата,Дата);
			Движение.Организация		= Организация;
			Движение.СчетДт				= ТаблицаНоменклатуры[0].СчетУчетаБУ;
			Движение.Получатель			= Склад;
			Движение.СчетКт				= СтрокаРасходыВключаемыеВСтоимость.СчетКредит;
			Движение.Сумма				= Остаток;
			Движение.СуммаНДС			= ОстатокНДС;
			Движение.Поставщик			= СтрокаРасходыВключаемыеВСтоимость.Субконто1;
			Движение.Договор			= СтрокаРасходыВключаемыеВСтоимость.Субконто2;
			Движение.ПриходныйДокумент	= СтрокаРасходыВключаемыеВСтоимость.ПриходныйДокумент;
			Движение.ЗачетНДС			= ПолучитьТипЗачетаНДС(ТаблицаНоменклатуры[0].СчетУчетаБУ,Истина);
			Движение.СтавкаНДС			= СтрокаРасходыВключаемыеВСтоимость.СтавкаНДС;
			Движение.ПорядокУплатыНДС	= ПорядокУплатыНДС;
		КонецЕсли;
		Если ПорядокУплатыНДС=Перечисления.ПорядокУплатыНДС.Общеустановленный И СтрокаРасходыВключаемыеВСтоимость.СуммаНДС<>0 Тогда
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание	 = "НДС по доп.расходам";     
			Проводка.ПервичныйДокумент = СформироватьОписаниеПервичногоДокумента(СтрокаРасходыВключаемыеВСтоимость.ПриходныйДокумент);     
			//
			Проводка.СчетДт = СчетУчетаАвансаПлатежа("НДС");
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,"СтавкиНДС",СтрокаРасходыВключаемыеВСтоимость.СтавкаНДС);
			//
			Проводка.СчетКт = СтрокаРасходыВключаемыеВСтоимость.СчетКредит;
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокаРасходыВключаемыеВСтоимость.Субконто1);
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,СтрокаРасходыВключаемыеВСтоимость.Субконто2);
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,3,СтрокаРасходыВключаемыеВСтоимость.Субконто3);
			//
			Проводка.Сумма = СтрокаРасходыВключаемыеВСтоимость.СуммаНДС; 
		КонецЕсли; 
	КонецЦикла; 
	Для Каждого СтрокаПрочее Из Прочее Цикл
		Проводка = ПроводкиБУ.Добавить();
		Проводка.Период      = Дата;
		Проводка.Организация = Организация;
		Проводка.Содержание	 = СтрокаПрочее.Описание;     
		Проводка.ПервичныйДокумент = СформироватьОписаниеПервичногоДокумента(ПриходныйДокумент);     
		//
		Проводка.СчетДт = СтрокаПрочее.СчетДебет;
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаПрочее.СубконтоД1);
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СтрокаПрочее.СубконтоД2);
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,СтрокаПрочее.СубконтоД3);
		//
		Проводка.СчетКт = СтрокаПрочее.СчетКредит;
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокаПрочее.СубконтоК1);
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,СтрокаПрочее.СубконтоК2);
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,3,СтрокаПрочее.СубконтоК3);
		//
		Проводка.Сумма = СтрокаПрочее.Сумма; 
		////
		Если СтрокаПрочее.СуммаНДС<>0 Тогда
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание	 = СтрокаПрочее.Описание;     
			Проводка.ПервичныйДокумент = СформироватьОписаниеПервичногоДокумента(ПриходныйДокумент);     
			//
			Если ПорядокУплатыНДС = Перечисления.ПорядокУплатыНДС.Общеустановленный Тогда
				Проводка.СчетДт = СчетУчетаАвансаПлатежа("НДС");
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,"НалогиИОбязательныеПлатежи",Справочники.ПлатежиВБюджет.НДС);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,"СтавкиНДС",СтрокаПрочее.СтавкаНДС);
			Иначе
				Проводка.СчетДт = СтрокаПрочее.СчетДебет;
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаПрочее.СубконтоД1);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СтрокаПрочее.СубконтоД2);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,СтрокаПрочее.СубконтоД3);
			КонецЕсли; 
			//
			Проводка.СчетКт = СтрокаПрочее.СчетКредит;
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокаПрочее.СубконтоК1);
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,СтрокаПрочее.СубконтоК2);
			УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,3,СтрокаПрочее.СубконтоК3);
			//
			Проводка.Сумма = СтрокаПрочее.СуммаНДС; 
		КонецЕсли; 
		////
		Движение = ТаблицаЗачетаНДС.Добавить();
		Движение.Период				= ?(ЗначениеЗаполнено(ПриходныйДокументДата),ПриходныйДокументДата,Дата);
		Движение.Организация		= Организация;
		Движение.СчетДт				= СтрокаПрочее.СчетДебет;
		Движение.Получатель			= СтрокаПрочее.СубконтоД1;
		Движение.СчетКт				= СтрокаПрочее.СчетКредит;
		Движение.Сумма				= СтрокаПрочее.Сумма;
		Движение.СуммаНДС			= СтрокаПрочее.СуммаНДС;
		Движение.Поставщик			= СтрокаПрочее.СубконтоК1;
		Движение.Договор			= СтрокаПрочее.СубконтоК2;
		Движение.ПриходныйДокумент	= ПриходныйДокумент;
		Движение.ЗачетНДС			= ПолучитьТипЗачетаНДС(СтрокаПрочее.СчетДебет,Истина);
		Движение.СтавкаНДС			= СтрокаПрочее.СтавкаНДС;
		Движение.ПорядокУплатыНДС	= ПорядокУплатыНДС;
	КонецЦикла; 
	ТаблицаЗачетаНДС.Свернуть("Период,Организация,СчетДт,Получатель,СчетКт,Поставщик,Договор,ПриходныйДокумент,ЗачетНДС,СтавкаНДС,ПорядокУплатыНДС","Сумма,СуммаНДС,СуммаНДСПоУслугам,СуммаНДСПоИмпорту");	
	Движения.УчетЗачетаНДС.Загрузить(ТаблицаЗачетаНДС);
	Если ЗачестьАванс Тогда
		Движения.Хозрасчетный.Записать();
		ЗачетАвансов.ВыполнитьЗакрытиеАвансов(ЭтотОбъект, СчетУчетаРасчетовСКонтрагентом, Поставщик,ДоговорПоставщика);
	КонецЕсли;
КонецПроцедуры
