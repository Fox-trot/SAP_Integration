﻿
&НаКлиенте
Процедура ПолеТабличногоДокументаОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;

	// Получение значений полей выбранной строки.

	ТабличныйДокумент = ПолеТабличногоДокумента;
	ТекущаяОбласть    = ТабличныйДокумент.ТекущаяОбласть;

	ОбластьDestRegion   = ТабличныйДокумент.Области.DestRegion;
	ОбластьDistDistrict = ТабличныйДокумент.Области.DistDistrict;

	DestRegion   = ТабличныйДокумент.Область(ТекущаяОбласть.Верх, ОбластьDestRegion.Лево, ТекущаяОбласть.Низ, ОбластьDestRegion.Право).Текст;
	DistDistrict = ТабличныйДокумент.Область(ТекущаяОбласть.Верх, ОбластьDistDistrict.Лево, ТекущаяОбласть.Низ, ОбластьDistDistrict.Право).Текст;

	ВладелецФормы.КодМестонахождения = Формат(Число(DestRegion), "ЧЦ=2; ЧН=; ЧВН=") + Формат(Число(DistDistrict), "ЧЦ=2; ЧН=; ЧВН=");
	
	ЭтаФорма.Закрыть();

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Макет = ПолучитьОбщийМакет("РегионыИРайоны");

	Макет.Параметры.Расшифровка = Истина; // чтобы работала расшифровка

	ТабличныйДокумент = ПолеТабличногоДокумента;

	ТабличныйДокумент.Очистить();
	ТабличныйДокумент.Вывести(Макет);

	ТабличныйДокумент.ФиксацияСверху      = ТабличныйДокумент.Области.ОбластьРасшифровки.Верх - 1;

	ТабличныйДокумент.ОтображатьЗаголовки = Ложь;
	ТабличныйДокумент.ОтображатьСетку     = Ложь;
	ТабличныйДокумент.ТолькоПросмотр      = Истина;
	
КонецПроцедуры
