﻿&НаСервере
Перем НаСервере;


&НаСервере
Функция НаСервере()
	Если НаСервере = Неопределено Тогда
		НаСервере = РеквизитФормыВЗначение("Объект");
	КонецЕсли;
	Возврат НаСервере;
КонецФункции

&НаСервере
Процедура ZFI_011_RFC_OZBEKISTAN2НаСервере()
	НаСервере().ZFI_011_RFC_OZBEKISTAN(Объект.ZFI_011_FG_1C);
КонецПроцедуры

&НаКлиенте
Процедура ZFI_011_RFC_OZBEKISTAN2(Команда)
	ZFI_011_RFC_OZBEKISTAN2НаСервере();
КонецПроцедуры

&НаСервере
Функция ZFI_011_RFC_OZBEKISTAN_RTRNНаСервере()
	Возврат НаСервере().ZFI_011_RFC_OZBEKISTAN_RTRN_TEST();
КонецФункции

&НаКлиенте
Процедура ZFI_011_RFC_OZBEKISTAN_RTRN(Команда)
	Ответ	= ZFI_011_RFC_OZBEKISTAN_RTRNНаСервере();
КонецПроцедуры

&НаСервере
Процедура ZFI_011_RFC_OZBEKISTANНаСервере()
	НаСервере().ZFI_011_RFC_OZBEKISTAN(Объект.ZFI_011_S_DATA);
КонецПроцедуры

&НаКлиенте
Процедура ZFI_011_RFC_OZBEKISTAN(Команда)
	ZFI_011_RFC_OZBEKISTANНаСервере();
КонецПроцедуры

&НаСервере
Функция КомандаПодтвердитьНаСервере(Знач ВыделенныеСтроки)
	НаСервере	= НаСервере();
	Если НаСервере.ZFI_011_RFC_OZBEKISTAN_RTRN(ВыделенныеСтроки) Тогда
		Объект.ZFI_011_S_DATA.Загрузить(НаСервере.ZFI_011_RFC_OZBEKISTAN());
		Возврат Истина;
	КонецЕсли;
	Возврат Ложь;
КонецФункции

&НаКлиенте
Процедура КомандаПодтвердить(Команда)
	Если Элементы.ZFI_011_S_DATA.ВыделенныеСтроки.Количество() > 0 Тогда
		МассивСтрок = Новый Массив;
		Для Каждого ТекущаяСтрока Из Элементы.ZFI_011_S_DATA.ВыделенныеСтроки Цикл
			СтрокаТаблицы = Объект.ZFI_011_S_DATA.НайтиПоИдентификатору(ТекущаяСтрока);
			Если СтрокаТаблицы <> Неопределено Тогда
				МассивСтрок.Добавить(СтрокаТаблицы);
			КонецЕсли;
		КонецЦикла;
		Если МассивСтрок.Количество() > 0
		И КомандаПодтвердитьНаСервере(МассивСтрок)
		Тогда
			ОбновитьИнтерфейс();
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ZSD_010_RFC_OZB_IADE_TESНаСервере()
	НаСервере().ZSD_010_RFC_OZB_IADE_TES(Объект.ZSD_010_S_DATA);
КонецПроцедуры

&НаКлиенте
Процедура ZSD_010_RFC_OZB_IADE_TES(Команда)
	ZSD_010_RFC_OZB_IADE_TESНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ZSD_010_RFC_OZB_FAT_IA_DEKONT(Команда)
	ZSD_010_RFC_OZB_FAT_IA_DEKONTНаСервере();
КонецПроцедуры

&НаСервере
Процедура ZSD_010_RFC_OZB_FAT_IA_DEKONTНаСервере()
	НаСервере().ZSD_010_RFC_OZB_FAT_IA_DEKONT(Объект.ZSD_011_S_DATA);
КонецПроцедуры

&НаКлиенте
Процедура ZMM_000_FM_1C_FATURA_LISTESI(Команда)
	ZMM_000_FM_1C_FATURA_LISTESIНаСервере();
КонецПроцедуры

&НаСервере
Процедура ZMM_000_FM_1C_FATURA_LISTESIНаСервере()
	Если Объект.ЭтоТест Тогда
		ZMM_000_FM_1C_FATURA_LISTESI_Заполнить();
	Иначе
		НаСервере().ZMM_000_FM_1C_FATURA_LISTESI(Объект.ZMM_000_S_1C_ENTEGRASYON_LIST);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ZMM_000_FM_1C_FATURA_LISTESI_Заполнить()
	Объект.ZMM_000_S_1C_ENTEGRASYON_LIST.Очистить();
	
	ТекСтрока	= Новый Структура("SIRKET_KODU,MUHASEBE_BELGE_NO,YIL,MUHASEBE_BELGE_KALEM,FATURA_NO,MASRAF_TIPI,MASRAF_TIPI_TX,TESLIMAT,TESLIMAT_KALEM,MIKTAR,OLCU_BIRIMI,TUTAR,PARA_BIRIMI,FATURA_BELGE_NO,VERGI_GOSTERGE,VERGI_TUTAR,TOPLAM_TUTAR,BIRIM_FIYAT,SATICI,SATICI_VKN,SATICI_TX,SATINALMA_SIPARIS,SATINALMA_SIPARIS_KALEM,MALZEME,MALZEME_TX,PARTI,SKT,KAYIT_TARIH,TERS_KAYIT_BELGE_NO,TERS_KAYIT_BELGE_YIL");
	Макет		= НаСервере().ПолучитьМакет("ZMM_000_S_1C_ENTEGRASYON_LIST");
	Для Итератор = 2 По Макет.ВысотаТаблицы Цикл
		ТекСтрока.SIRKET_KODU			= Макет.Область(Итератор, 1).Текст;
		ТекСтрока.MUHASEBE_BELGE_NO		= Макет.Область(Итератор, 2).Текст;
		ТекСтрока.YIL					= Макет.Область(Итератор, 3).Текст;
		ТекСтрока.MUHASEBE_BELGE_KALEM	= Макет.Область(Итератор, 4).Текст;
		ТекСтрока.FATURA_NO				= Макет.Область(Итератор, 5).Текст;
		ТекСтрока.MASRAF_TIPI			= Макет.Область(Итератор, 6).Текст;
		ТекСтрока.MASRAF_TIPI_TX		= Макет.Область(Итератор, 7).Текст;
		ТекСтрока.TESLIMAT				= Макет.Область(Итератор, 8).Текст;
		ТекСтрока.TESLIMAT_KALEM		= Макет.Область(Итератор, 9).Текст;
		ТекСтрока.MIKTAR				= Макет.Область(Итератор, 10).Текст;
		ТекСтрока.OLCU_BIRIMI			= Макет.Область(Итератор, 11).Текст;
		ТекСтрока.TUTAR					= Макет.Область(Итератор, 12).Текст;
		ТекСтрока.PARA_BIRIMI			= Макет.Область(Итератор, 13).Текст;
		ТекСтрока.FATURA_BELGE_NO		= Макет.Область(Итератор, 14).Текст;
		ТекСтрока.VERGI_GOSTERGE		= Макет.Область(Итератор, 15).Текст;
		ТекСтрока.VERGI_TUTAR			= Макет.Область(Итератор, 16).Текст;
		ТекСтрока.TOPLAM_TUTAR			= Макет.Область(Итератор, 17).Текст;
		ТекСтрока.BIRIM_FIYAT			= Макет.Область(Итератор, 18).Текст;
		ТекСтрока.SATICI				= Макет.Область(Итератор, 19).Текст;
		ТекСтрока.SATICI_VKN			= Макет.Область(Итератор, 20).Текст;
		ТекСтрока.SATICI_TX				= Макет.Область(Итератор, 21).Текст;
		ТекСтрока.SATINALMA_SIPARIS		= Макет.Область(Итератор, 22).Текст;
		ТекСтрока.SATINALMA_SIPARIS_KALEM= Макет.Область(Итератор, 23).Текст;
		ТекСтрока.MALZEME				= Макет.Область(Итератор, 24).Текст;
		ТекСтрока.MALZEME_TX			= Макет.Область(Итератор, 25).Текст;
		ТекСтрока.PARTI					= Макет.Область(Итератор, 26).Текст;
		ТекСтрока.SKT					= Макет.Область(Итератор, 27).Текст;
		ТекСтрока.KAYIT_TARIH			= Макет.Область(Итератор, 28).Текст;
		ТекСтрока.TERS_KAYIT_BELGE_NO	= Макет.Область(Итератор, 29).Текст;
		ТекСтрока.TERS_KAYIT_BELGE_YIL	= Макет.Область(Итератор, 30).Текст;
		ЗаполнитьЗначенияСвойств(Объект.ZMM_000_S_1C_ENTEGRASYON_LIST.Добавить(), ТекСтрока);
	КонецЦикла;
	Объект.ZMM_000_S_1C_ENTEGRASYON_LIST.Сортировать("MUHASEBE_BELGE_NO,MUHASEBE_BELGE_KALEM");
КонецПроцедуры

&НаСервере
Процедура ZMM_000_FM_1C_MAL_HAREKETIНаСервере()
	НаСервере().ZMM_000_FM_1C_MAL_HAREKETI(Объект.ZMM_000_S_1C_ILAC_ALIM);
КонецПроцедуры

&НаКлиенте
Процедура ZMM_000_FM_1C_MAL_HAREKETI(Команда)
	ZMM_000_FM_1C_MAL_HAREKETIНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ТекстЗапросаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	КомандаФайлЗагрузить();
КонецПроцедуры

&НаКлиенте
Процедура КомандаФайлЗагрузить(Команда=Неопределено)
	ВариантЗагрузки	= 1;
	
	ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогОткрытияФайла.МножественныйВыбор	= Ложь;
	ДиалогОткрытияФайла.Фильтр				= "Текстовый документ (*.xml)|*.xml|Текстовый документ (*.txt)|*.txt";
	ДиалогОткрытияФайла.Показать(Новый ОписаниеОповещения("ВыборФайлаЗавершение", ЭтотОбъект));
КонецПроцедуры

&НаКлиенте
Процедура ВыборФайлаЗавершение(ВыбранныеФайлы, Контекст) Экспорт
	Если ТипЗнч(ВыбранныеФайлы) = Тип("Массив") Тогда
		Для Каждого _ИмяФайла Из ВыбранныеФайлы Цикл
			Попытка
				Если ВариантЗагрузки = 1 Тогда
					Конвертировать(_ИмяФайла);
					ИмяФайла	= "file:///" + СтрЗаменить(_ИмяФайла, "\", "/");
				Иначе
					ПолноеИмяФайла	= _ИмяФайла;
					Попытка
						НачатьПомещениеФайла(Новый ОписаниеОповещения("ВыполнитьЗагрузку", ЭтаФорма),, ПолноеИмяФайла, Ложь);
					Исключение
						Сообщить(ОписаниеОшибки());
					КонецПопытки;
				КонецЕсли;
			Исключение
				Сообщить(ОписаниеОшибки());
			КонецПопытки;
		КонецЦикла;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьЗагрузку(Результат, Адрес, _ИмяФайла, ДополнительныеПараметры) Экспорт
	Если Результат Тогда
	    ЗагрузитьНаСервере(Адрес, Сред(_ИмяФайла, СтрНайти(_ИмяФайла, ".", НаправлениеПоиска.СКонца) + 1));
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьНаСервере(Знач Адрес, Расширение)
	ФайлВременногоХранилища = ПолучитьИзВременногоХранилища(Адрес);
    ИмяФайла				= ПолучитьИмяВременногоФайла(Расширение);
	Попытка
	    ФайлВременногоХранилища.Записать(ИмяФайла);
	    УдалитьИзВременногоХранилища(Адрес);
		ТабДок.Прочитать(ИмяФайла);
	Исключение
		Сообщить(ОписаниеОшибки());
		Возврат;
	КонецПопытки;
	УдалитьФайлы(ИмяФайла);
	//	обработка файла
	СоответсвияЗагрузитьНаСервере();
КонецПроцедуры

//	file:///D:/s1/apt/2.xml
&НаКлиенте
Функция Конвертировать(ПолноеИмя)
	ШалостьУдалась	= Ложь;
	portType		= "";
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.ОткрытьФайл(ПолноеИмя);
	ПостроительDOM		= Новый ПостроительDOM;
	ДокументDOM			= ПостроительDOM.Прочитать(ЧтениеXML);
	ЧтениеXML.Закрыть();
	Виктимз	= Новый Массив;
	Для Каждого Дом2 Из ДокументDOM.ДочерниеУзлы Цикл
		Виктимз.Очистить();
		Для Каждого Виктим Из Дом2.ДочерниеУзлы Цикл
			Если СтрСравнить(Виктим.ИмяУзла, "wsp:Policy") = 0
			Или СтрСравнить(Виктим.ИмяУзла, "wsp:UsingPolicy") = 0
			Или СтрСравнить(Виктим.ИмяУзла, "wsdl:documentation") = 0
			Тогда
				Виктимз.Добавить(Виктим);
				ШалостьУдалась = Истина;
			Иначе
				УдалитьДочерний(Виктим, ШалостьУдалась);
				Если ПустаяСтрока(portType) И СтрСравнить(Виктим.ИмяУзла, "wsdl:portType") = 0 Тогда
					Для Каждого Атрибут Из Виктим.Атрибуты Цикл
						Если СтрСравнить(Атрибут.Имя, "name") = 0 Тогда
							portType	= Атрибут.Значение;
							Прервать;
						КонецЕсли;
					КонецЦикла;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
		Для Каждого Виктим Из Виктимз Цикл
			Дом2.УдалитьДочерний(Виктим);
			ШалостьУдалась = Истина;
		КонецЦикла;
	КонецЦикла;
	Если ШалостьУдалась Тогда
		ЗаписьXML = Новый ЗаписьXML;
		ЗаписьXML.ОткрытьФайл(ПолноеИмя);
		ЗаписьDOM = Новый ЗаписьDOM;
		ЗаписьDOM.Записать(ДокументDOM, ЗаписьXML);
		ЗаписьXML.Закрыть();
	КонецЕсли;
	Возврат ШалостьУдалась;
КонецФункции

&НаКлиенте
Процедура УдалитьДочерний(Узел, ШалостьУдалась)
	Виктимз	= Новый Массив;
	Для Каждого Виктим Из Узел.ДочерниеУзлы Цикл
		Если СтрСравнить(Виктим.ИмяУзла, "wsp:Policy") = 0 Тогда
			Виктимз.Добавить(Виктим);
		Иначе
			 УдалитьДочерний(Виктим, ШалостьУдалась);
		КонецЕсли;
	КонецЦикла;
	Для Каждого Виктим Из Виктимз Цикл
		Узел.УдалитьДочерний(Виктим);
		ШалостьУдалась = Истина;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура КомандаПоступлениеНоменклатурыСоздать(Команда)
	Если ПроверитьЗаполнение() Тогда
		КомандаПоступлениеНоменклатурыСоздатьНаСервере();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура КомандаПоступлениеНоменклатурыСоздатьНаСервере()
	НаСервере().ПоступленияНоменклатурыСоздать(Объект.ZMM_000_S_1C_ENTEGRASYON_LIST);
КонецПроцедуры

&НаСервере
Процедура Настроить()
	НаСервере().Настроить(Объект);
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Настроить();
КонецПроцедуры

&НаСервере
Процедура СоответсвияЗагрузитьНаСервере()
	Объект.Соответствия.Очистить();
	
	Колонка_Код				= 1;
	Колонка_Код1С			= 2;
	Колонка_Серия			= 4;
	Колонка_Наименование	= 2;
	Итератор				= 3;
	Пока Итератор <= ?(Объект.ЭтоТест, 9, ТабДок.ВысотаТаблицы) Цикл
		Код		= ОбластьПрочитать(Итератор, Колонка_Код);
		Если ПустаяСтрока(Код) Тогда Прервать; КонецЕсли;
		Код1С	= ОбластьПрочитать(Итератор, Колонка_Код1С);
		Серия	= ОбластьПрочитать(Итератор, Колонка_Серия);
		НоменклатураПродаж	= НоменклатураПродажНайти(Код1С, Серия);
		
		Если ЗначениеЗаполнено(НоменклатураПродаж) Тогда
			ЗаполнитьЗначенияСвойств(Объект.Соответствия.Добавить(), Новый Структура("Код,Ссылка", Код + "/" + Серия, НоменклатураПродаж));
		КонецЕсли;
		
		Итератор = Итератор + 1;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Функция ОбластьПрочитать(НомерСтроки, НомерКолонки)
	Возврат СокрЛП(ТабДок.Область(НомерСтроки, НомерКолонки, НомерСтроки, НомерКолонки).Текст);
КонецФункции

&НаКлиенте
Процедура СоответсвияЗагрузить(Команда)
	ВариантЗагрузки	= 2;
	ПолноеИмяФайла	= "";
	
	ДиалогОткрытияФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогОткрытияФайла.Фильтр = "Файл Microsoft Excel (*.xlsx)|*.xlsx|Табличный документ (*.mxl)|*.mxl";
	ДиалогОткрытияФайла.МножественныйВыбор = Ложь;
	ДиалогОткрытияФайла.Показать(Новый ОписаниеОповещения("ВыборФайлаЗавершение", ЭтотОбъект));
КонецПроцедуры

&НаСервере
Функция НоменклатураПродажНайти(Код, Серия)
	Возврат НаСервере().НоменклатураПродажНайти(Код, Серия);
КонецФункции

&НаКлиенте
Процедура СоответствияЗаписать(Команда)
	СоответствияЗаписатьНаСервере();
КонецПроцедуры

&НаСервере
Процедура СоответствияЗаписатьНаСервере()
	Для Каждого ТекСтрока Из Объект.Соответствия Цикл
		НЗ = РегистрыСведений.Соответствия.СоздатьНаборЗаписей();
		НЗ.Отбор.Ссылка.Установить(ТекСтрока.Ссылка);
		НЗ.Отбор.Код.Установить(ТекСтрока.Код);
		НЗ.Прочитать();
		Если НЗ.Количество() = 0 Тогда
			ЗаполнитьЗначенияСвойств(НЗ.Добавить(), ТекСтрока);
			НЗ.Записать();
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура РеализацияМедикаментовСоздатьНаСервере()
	НаСервере().РеализацияМедикаментовСоздатьНаСервере(Объект.ZSD_011_S_DATA);
КонецПроцедуры

&НаКлиенте
Процедура РеализацияМедикаментовСоздать(Команда)
	Если ПроверитьЗаполнение() Тогда
		РеализацияМедикаментовСоздатьНаСервере();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура УслугиСтороннихСоздать(Команда)
	Если ПроверитьЗаполнение() Тогда
		УслугиСтороннихСоздатьНаСервере();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура УслугиСтороннихСоздатьНаСервере()
	НаСервере().УслугиСтороннихСоздатьНаСервере(Объект.ZFI_011_FG_1C);
КонецПроцедуры
