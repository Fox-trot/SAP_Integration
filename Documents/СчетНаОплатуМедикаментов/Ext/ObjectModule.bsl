﻿
Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	
	ДобавитьПрефиксУзла(Префикс);
	
КонецПроцедуры

Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("СчетНаОплату","Счет на оплату");
	
КонецФункции

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	СуммаПоДокументу=Номенклатура.Итог("Сумма")+Номенклатура.Итог("СуммаНДС")+Услуги.Итог("Сумма")+Услуги.Итог("СуммаНДС");
	КоличествоПоДокументу=0;
	
КонецПроцедуры

Процедура ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента)
	
	//Проверяем заполнение шапки
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	СтруктураОбязательныхПолей.Вставить("БанковскийСчет","Не выбран вид банковский счет");
	СтруктураОбязательныхПолей.Вставить("Контрагент","Не выбран вид контрагент");
	
	
	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	
	//Проверяем заполнение табличной части 
	
	СтруктураПолей = Новый Структура();
	СтруктураПолей.Вставить("Номенклатура","Не выбрана номенклатура");
	СтруктураПолей.Вставить("СчетУчетаБУ","Не выбран счет учета номенклатуры");
	
	ПроверитьЗаполнениеТабличнойЧастиПлатежногоДокумента(ЭтотОбъект, "Номенклатура", СтруктураПолей, Отказ, Заголовок);
	
КонецПроцедуры

Функция ПечатьСчетНаОплату()
	
	ТабДок = Новый ТабличныйДокумент;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СчетНаОплатуМедикаментовНоменклатура.Номенклатура,
	|	СчетНаОплатуМедикаментовНоменклатура.Количество,
	|	СчетНаОплатуМедикаментовНоменклатура.Сумма КАК Сумма,
	|	СчетНаОплатуМедикаментовНоменклатура.ЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	СчетНаОплатуМедикаментовНоменклатура.Цена КАК Цена,
	|	СчетНаОплатуМедикаментовНоменклатура.СуммаНДС КАК СуммаНДС,
	|	СчетНаОплатуМедикаментовНоменклатура.СтавкаНДС,
	|	СчетНаОплатуМедикаментовНоменклатура.НомерСтроки КАК НомерСтроки,
	|	ВЫБОР
	|		КОГДА СчетНаОплатуМедикаментовНоменклатура.СуммаНДС = 0
	|			ТОГДА 0
	|		ИНАЧЕ СчетНаОплатуМедикаментовНоменклатура.Сумма + СчетНаОплатуМедикаментовНоменклатура.СуммаНДС
	|	КОНЕЦ КАК Всего,
	|	СчетНаОплатуМедикаментовНоменклатура.Сумма + СчетНаОплатуМедикаментовНоменклатура.СуммаНДС КАК СуммаСУчетомАкцизаИНДС,
	|	СчетНаОплатуМедикаментовНоменклатура.Серия,
	|	СчетНаОплатуМедикаментовНоменклатура.Себестоимость,
	|	СчетНаОплатуМедикаментовНоменклатура.Наценка,
	|	СчетНаОплатуМедикаментовНоменклатура.Номенклатура.ПроисхождениеТовара КАК Происхождение
	|ИЗ
	|	Документ.СчетНаОплатуМедикаментов.Номенклатура КАК СчетНаОплатуМедикаментовНоменклатура
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.СчетНаОплатуМедикаментов КАК СчетНаОплатуМедикаментов
	|		ПО СчетНаОплатуМедикаментовНоменклатура.Ссылка = СчетНаОплатуМедикаментов.Ссылка
	|ГДЕ
	|	СчетНаОплатуМедикаментов.Ссылка = &Ссылка
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	СчетНаОплатуМедикаментовУслуги.Услуга,
	|	NULL,
	|	СчетНаОплатуМедикаментовУслуги.Сумма,
	|	СчетНаОплатуМедикаментовУслуги.Услуга.БазоваяЕдиницаИзмерения,
	|	NULL,
	|	СчетНаОплатуМедикаментовУслуги.СуммаНДС,
	|	СчетНаОплатуМедикаментовУслуги.СтавкаНДС,
	|	СчетНаОплатуМедикаментовУслуги.НомерСтроки,
	|	ВЫБОР
	|		КОГДА СчетНаОплатуМедикаментовУслуги.СуммаНДС = 0
	|			ТОГДА 0
	|		ИНАЧЕ СчетНаОплатуМедикаментовУслуги.Сумма + СчетНаОплатуМедикаментовУслуги.СуммаНДС
	|	КОНЕЦ,
	|	СчетНаОплатуМедикаментовУслуги.Сумма + СчетНаОплатуМедикаментовУслуги.СуммаНДС,
	|	NULL,
	|	NULL,
	|	NULL,
	|	СчетНаОплатуМедикаментовУслуги.Услуга.ПроисхождениеТовара
	|ИЗ
	|	Документ.СчетНаОплатуМедикаментов.Услуги КАК СчетНаОплатуМедикаментовУслуги
	|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.СчетНаОплатуМедикаментов КАК СчетНаОплатуМедикаментов
	|		ПО СчетНаОплатуМедикаментовУслуги.Ссылка = СчетНаОплатуМедикаментов.Ссылка
	|ГДЕ
	|	СчетНаОплатуМедикаментов.Ссылка = &Ссылка
	|
	|УПОРЯДОЧИТЬ ПО
	|	НомерСтроки
	|ИТОГИ
	|	СУММА(Сумма),
	|	СУММА(СуммаНДС),
	|	СУММА(Всего),
	|	СУММА(СуммаСУчетомАкцизаИНДС)
	|ПО
	|	ОБЩИЕ";
	
	Запрос.УстановитьПараметр("Ссылка",Ссылка );
	
	Результат = Запрос.Выполнить();
	ВыборкаОбщие = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	ВыборкаОбщие.Следующий();
	
	//==================================================
	Если Дата>Дата(2019,01,21) Тогда
		Макет = ПолучитьМакет("СчетНаОплату");
	Иначе 	
		Макет = ПолучитьМакет("СчетНаОплату2018");
	КонецЕсли;
	
	//Макет = ПолучитьМакет("СчетНаОплату");
	
	СведенияОбОрганизации = СведенияОЮрФизЛице(Организация, БанковскийСчет, Дата);
	СведенияОКонтрагенте  = СведенияОЮрФизЛице(Контрагент, БанковскийСчетКонтрагента, Дата);
	
	Область = Макет.ПолучитьОбласть("Заголовок");
	Область.Параметры.ДоговорПродажи	= ДоговорКонтрагента.Наименование;
	Область.Параметры.Номер				= ПолучитьНомерНаПечать(ЭтотОбъект);
	Область.Параметры.Дата				= Формат(Дата,"ДЛФ=D")+" г.";
	ТабДок.Вывести(Область);
	
	Если Контрагент.ЮрФизЛицо=Перечисления.ЮрФизЛицо.ФизЛицо Тогда
		Область = Макет.ПолучитьОбласть("ШапкаФизЛицо");
	Иначе	
		Область = Макет.ПолучитьОбласть("Шапка");
	КонецЕсли;
	Область.Параметры.Заполнить(СведенияОбОрганизации);
	Область.Параметры.Заполнить(СведенияОКонтрагенте);
	ТабДок.Вывести(Область);
	
	номерСтроки = 0;
	
	Выборка = ВыборкаОбщие.Выбрать();
	Пока Выборка.Следующий() Цикл
		номерСтроки = номерСтроки+1;
		Если Выборка.СтавкаНДС = Перечисления.СтавкиНДС.БезНДС ИЛИ
			 Выборка.СтавкаНДС = Перечисления.СтавкиНДС.ПустаяСсылка()Тогда
			Область = Макет.ПолучитьОбласть("СтрокаБезНДС");
		Иначе	
			Область = Макет.ПолучитьОбласть("Строка");
		КонецЕсли;
		
		Область.Параметры.Заполнить(Выборка);
		Область.Параметры.номерСтроки = номерСтроки;
		ТабДок.Вывести(Область);
	КонецЦикла;
	
	Если ФинансоваяСкидкаПроцент=0 Тогда
		Область = Макет.ПолучитьОбласть("Подвал");
	Иначе
		Область = Макет.ПолучитьОбласть("ПодвалСкидка");
	КонецЕсли;
	
	Область.Параметры.Заполнить(ВыборкаОбщие);
	
	Всего=0;
	
	Попытка
		Всего = ВыборкаОбщие.Сумма + ВыборкаОбщие.СуммаНДС;
	Исключение
	КонецПопытки;
	
	Руководители = ОтветственныеЛица(Организация, Дата);	
    Область.Параметры.Заполнить(Руководители);
	
	Если ФинансоваяСкидкаПроцент=0 Тогда
		Область.Параметры.ВсегоПрописью	= СформироватьСуммуПрописью(Всего, Константы.ВалютаРегламентированногоУчета.Получить());
	Иначе
		Область.Параметры.ФинансоваяСкидкаПроцент=ФинансоваяСкидкаПроцент;
  		Область.Параметры.ФинансоваяСкидкаСумма=ФинансоваяСкидкаСумма;
  		Область.Параметры.СуммаБезСкидки=Всего-ФинансоваяСкидкаСумма;
		Область.Параметры.ВсегоПрописью	= СформироватьСуммуПрописью(Всего-ФинансоваяСкидкаСумма, Константы.ВалютаРегламентированногоУчета.Получить());
	КонецЕсли;
	
	ТабДок.Вывести(Область);
	
	ТабДок.ФиксацияСверху			= 0;
	ТабДок.ФиксацияСлева			= 0;
	//ТабДок.ЭкземпляровНаСтранице	= 1;
	ТабДок.ТолькоПросмотр			= Истина;
	ТабДок.Автомасштаб				= Истина;
	ТабДок.ОриентацияСтраницы		= ОриентацияСтраницы.Портрет;
	
	ТабДок.КлючПараметровПечати="КПП_СчетНаОплатуМедикаментов";
	
	Возврат ТабДок;
	
КонецФункции // ПечатьСчетФактура()

Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	
	Если ИмяМакета="СчетНаОплату" Тогда
		ТабДокумент = ПечатьСчетНаОплату();
	КонецЕсли; 
	
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, "Счет-фактура");
	
КонецПроцедуры // Печать()
