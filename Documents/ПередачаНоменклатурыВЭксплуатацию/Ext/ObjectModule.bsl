﻿// Строки, хранят реквизиты имеющие смысл только для бух. учета и упр. соответственно
// в случае если документ не отражается в каком-то виде учета, делаются невидимыми
Перем мСтрокаРеквизитыБухУчета Экспорт; // (Регл)
Перем мДокументОснование       Экспорт;

Перем мУчетнаяПолитика;                 // (Общ)

Перем мВалютаРегламентированногоУчета Экспорт;

//#Если Клиент Тогда

Функция ПечатьАктСписания()

	ТабДок = Новый ТабличныйДокумент;
	Макет = ПолучитьМакет("АктСписания");
	
	Руководители = ОтветственныеЛица(Организация, Дата);	
	
	Область = Макет.ПолучитьОбласть("Шапка");
	Область.Параметры.Номер = ПолучитьНомерНаПечать(ЭтотОбъект);
	Область.Параметры.Дата = Формат(Дата,"ДФ=dd.MM.yyyy");
	Область.Параметры.Организация = Организация;
	Область.Параметры.Склад = Склад;
	Область.Параметры.Руководитель = Руководители.РуководительПредставление;
	
	ТабДок.Вывести(Область);
	
	Область = Макет.ПолучитьОбласть("Строка");
	Для Каждого СтрокаНоменклатуры из Материалы Цикл
		Область.Параметры.Заполнить(СтрокаНоменклатуры);
		Область.Параметры.КодНоменклатуры = СтрокаНоменклатуры.Номенклатура.Код;
		Область.Параметры.Цена = ?(СтрокаНоменклатуры.Количество<>0,СтрокаНоменклатуры.Сумма/СтрокаНоменклатуры.Количество,0);
		
		ТабДок.Вывести(Область);
	КонецЦикла; 
	
	Область = Макет.ПолучитьОбласть("Подвал");
	Область.Параметры.Количество = Материалы.Итог("Количество");
	Область.Параметры.Сумма = Материалы.Итог("Сумма");
	Область.Параметры.КоличествоПрописью = ЧислоПрописью(Материалы.Итог("Количество"),"НД=Ложь",",,,,,,,,0");
	
	Область.Параметры.ПредседательКомиссии = ФИОСотрудника(ПредседательКомиссии,Дата);
	Область.Параметры.ЧленКомиссии1 = ФИОСотрудника(ЧленКомиссии1,Дата);
	Область.Параметры.ЧленКомиссии2 = ФИОСотрудника(ЧленКомиссии2,Дата);
	Область.Параметры.ЧленКомиссии3 = ФИОСотрудника(ЧленКомиссии3,Дата);
	
	Область.Параметры.ДолжностьПредседателя = ДолжностьСотрудника(ПредседательКомиссии,Дата);
	Область.Параметры.ДолжностьЧК1 = ДолжностьСотрудника(ЧленКомиссии1,Дата);
	Область.Параметры.ДолжностьЧК2 = ДолжностьСотрудника(ЧленКомиссии2,Дата);
	Область.Параметры.ДолжностьЧК3 = ДолжностьСотрудника(ЧленКомиссии3,Дата);
	
	ТабДок.Вывести(Область);
	
	ТабДок.ФиксацияСверху=0;
	ТабДок.ФиксацияСлева=0;
	ТабДок.ЭкземпляровНаСтранице=0;
	ТабДок.ТолькоПросмотр = Истина;
	ТабДок.ОриентацияСтраницы = ОриентацияСтраницы.Ландшафт;
	ТабДок.АвтоМасштаб = Истина;

	Возврат ТабДок;

КонецФункции // ПечатьМ11()

// Процедура осуществляет печать документа. Можно направить печать на 
// экран или принтер, а также распечатать необходмое количество копий.
//
//  Название макета печати передается в качестве параметра,
// по переданному названию находим имя макета в соответствии.
//
// Параметры:
//  НазваниеМакета - строка, название макета.
//
Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	
	// Получить экземпляр документа на печать
	Если      ИмяМакета = "АктСписания" Тогда
		ТабДокумент = ПечатьАктСписания();
		
	КонецЕсли;
	
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, СформироватьЗаголовокДокумента(Ссылка), НепосредственнаяПечать);
	
КонецПроцедуры // Печать()

//#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//  Струткура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("АктСписания","Акт передачи в эксплуатацию материалов");

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

// Выгружает результат запроса в табличную часть, добавляет ей необходимые колонки для проведения.
//
// Параметры: 
//  РезультатЗапросаПоТоварам - результат запроса по табличной части "Товары",
//  СтруктураШапкиДокумента   - выборка по результату запроса по шапке документа.
//
// Возвращаемое значение:
//  Сформированная таблиица значений.
//
Функция ПодготовитьТаблицуТоваров(РезультатЗапросаПоТоварам, СтруктураШапкиДокумента)

	ТаблицаМатериалов = РезультатЗапросаПоТоварам.Выгрузить();

	ТаблицаМатериалов.Колонки.Добавить("ДокументОприходования");
	ТаблицаМатериалов.Колонки.Добавить("Регистратор");
	ТаблицаМатериалов.Колонки.Добавить("Склад");
	ТаблицаМатериалов.Колонки.Добавить("Организация");
	ТаблицаМатериалов.Колонки.Добавить("ДоговорКонтрагента");
	ТаблицаМатериалов.Колонки.Добавить("Валюта");
	ТаблицаМатериалов.Колонки.Добавить("ВходящийНДС");
	ТаблицаМатериалов.Колонки.Добавить("КоэффОплаты");
	КоэффОплаты      = 1;
	ТаблицаМатериалов.ЗаполнитьЗначения(КоэффОплаты,   							"КоэффОплаты");
	ТаблицаМатериалов.ЗаполнитьЗначения(ЭтотОбъект,    							"Регистратор");
	ТаблицаМатериалов.ЗаполнитьЗначения(СтруктураШапкиДокумента.Склад,      	"Склад");
	ТаблицаМатериалов.ЗаполнитьЗначения(СтруктураШапкиДокумента.Организация,	"Организация");
	

	
	Если ИспользоватьЕдиныйСчетЗатрат Тогда
		ТаблицаМатериалов.Колонки.Добавить("КорСчетСписанияБУ");
		ТаблицаМатериалов.Колонки.Добавить("КорСубконтоСписанияБУ1");
		ТаблицаМатериалов.Колонки.Добавить("КорСубконтоСписанияБУ2");
		ТаблицаМатериалов.Колонки.Добавить("КорСубконтоСписанияБУ3");
	
		ТаблицаМатериалов.ЗаполнитьЗначения(СчетЗатрат,    					    		"КорСчетСписанияБУ");
		ТаблицаМатериалов.ЗаполнитьЗначения(Субконто1,     				     			"КорСубконтоСписанияБУ1");
		ТаблицаМатериалов.ЗаполнитьЗначения(Субконто2,     				    			"КорСубконтоСписанияБУ2");
		ТаблицаМатериалов.ЗаполнитьЗначения(Субконто3,     					    		"КорСубконтоСписанияБУ3");
	КонецЕсли; 

	Возврат ТаблицаМатериалов;

КонецФункции // ПодготовитьТаблицуТоваров()

Процедура ДвиженияПоРегистрамПоУказаннойСтоимости(РежимПроведения,  Отказ, Заголовок, СтруктураШапкиДокумента)

	ПроверитьОстаткиМатериалов(Отказ,ЭтотОбъект,Материалы, Склад,Организация);
	Если ПараметрыСеанса.ВедетсяПартионныйУчет Тогда
		ДвиженияПоБУПоПартиям(РежимПроведения, Отказ, Заголовок ,СтруктураШапкиДокумента);
	Иначе	
		ДвиженияПоБУПоУказаннойСтоимости(РежимПроведения, Отказ, Заголовок ,СтруктураШапкиДокумента);
	КонецЕсли;	
	
КонецПроцедуры

Процедура ДвиженияПоБУПоУказаннойСтоимости(Режим, Отказ, Заголовок ,СтруктураШапкиДокумента)
	
	ПроводкиБУ = Движения.Хозрасчетный;
	
	Для Каждого СтрокаНоменклатуры Из Материалы Цикл
		
		
		Проводка = ПроводкиБУ.Добавить();
		Проводка.Период      = Дата;
		Проводка.Организация = Организация;
		Проводка.Содержание = "";     
		
		Если ИспользоватьЕдиныйСчетЗатрат и Не СписыватьНаРасходыБудущихПериодов Тогда
			Проводка.СчетДт      = СчетЗатрат;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Субконто1);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,Субконто2);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,Субконто3);
		ИначеЕсли Не ИспользоватьЕдиныйСчетЗатрат и Не СписыватьНаРасходыБудущихПериодов Тогда
			Проводка.СчетДт      = СтрокаНоменклатуры.СчетЗатрат;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаНоменклатуры.Субконто1);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СтрокаНоменклатуры.Субконто2);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,СтрокаНоменклатуры.Субконто3);
			
		Иначе
			Проводка.СчетДт      = ПланыСчетов.Хозрасчетный.А3190;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаНоменклатуры.РасходыБудущихПериодов);
			//УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СкладПолучатель);
			//УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,Дата);
			
		КонецЕсли; 
		Если СчетЗатрат.Количественный или Проводка.СчетДт.Количественный Тогда
			Проводка.КоличествоДт = СтрокаНоменклатуры.Количество;
		КонецЕсли; 
		
		Проводка.СчетКт     =  СтрокаНоменклатуры.Счет;
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокаНоменклатуры.Номенклатура);
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,Склад);
		Проводка.КоличествоКт = СтрокаНоменклатуры.Количество;
		
		Проводка.Сумма = СтрокаНоменклатуры.Сумма; 
		
		Если СтрокаНоменклатуры.СуммаНДС<>0 Тогда
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание = "";     
			
			Если ИспользоватьЕдиныйСчетЗатрат Тогда
				Проводка.СчетДт      = СчетЗатрат;
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Субконто1);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,Субконто2);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,Субконто3);
			Иначе
				Проводка.СчетДт      = СтрокаНоменклатуры.СчетЗатрат;
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаНоменклатуры.Субконто1);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СтрокаНоменклатуры.Субконто2);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,СтрокаНоменклатуры.Субконто3);
			КонецЕсли; 
			Если СчетЗатрат.Количественный Тогда
				Проводка.КоличествоДт = СтрокаНоменклатуры.Количество;
			КонецЕсли; 
			
			Проводка.СчетКт     =  СчетУчетаПлатежа("НДС");
			УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, 1, Справочники.ПлатежиВБюджет.НДС);
			Проводка.Сумма = СтрокаНоменклатуры.СуммаНДС; 
		КонецЕсли; 

		Если Не СписыватьНаРасходыБудущихПериодов Тогда
			
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			
			Проводка.СчетДт      = СчетУчетаМатериаловНаЗабалансе(СтрокаНоменклатуры.Счет);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаНоменклатуры.Номенклатура);
			Если ПолучательВТаблице Тогда
				Проводка.Содержание = ?(Сокрлп(СтрокаНоменклатуры.Требование)="","","Треб. № "+Сокрлп(СтрокаНоменклатуры.Требование));     
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СтрокаНоменклатуры.СкладПолучатель);
			Иначе
				Проводка.Содержание = ?(Сокрлп(Требование)="","","Треб. № "+Сокрлп(Требование));     
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СкладПолучатель);
			КонецЕсли;
			Проводка.КоличествоДт = СтрокаНоменклатуры.Количество;
			//УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,Дата);
			
			Проводка.Сумма = СтрокаНоменклатуры.Сумма;
		КонецЕсли;
	КонецЦикла; 
	
КонецПроцедуры

Процедура ДвиженияПоБУПоПартиям(Режим, Отказ, Заголовок, СтруктураШапкиДокумента)
	
	ПроводкиБУ = Движения.Хозрасчетный;
	
	СписокМПЗ = СкладскойУчет.ПолучитьНовыйСписокМПЗ();
	Для Каждого СтрокаНоменклатуры Из Материалы Цикл
		СтрокаСписка = СписокМПЗ.Добавить();
		СтрокаСписка.Номенклатура = СтрокаНоменклатуры.Номенклатура;
		СтрокаСписка.Склад = Склад;
		СтрокаСписка.СчетУчета = СтрокаНоменклатуры.Счет;
		СтрокаСписка.Количество = СтрокаНоменклатуры.Количество;
	КонецЦикла;	
	
	ТПартии = СкладскойУчет.ПолучитьТаблицуПартийПоСпискуМПЗ(СписокМПЗ, Дата, Организация);
	ТМатериалы = Материалы.ВыгрузитьКолонки();
	ТМатериалы.Колонки.Добавить("Партия");
	
	Для Каждого СтрокаНоменклатуры Из Материалы Цикл
		
		КоличествоСписать = СтрокаНоменклатуры.Количество;
		
		Партии = ТПартии.НайтиСтроки(Новый Структура("Номенклатура,СчетУчета",СтрокаНоменклатуры.Номенклатура,СтрокаНоменклатуры.Счет));
		Для каждого Партия Из Партии Цикл
			
			КоличествоПоПартии = Партия.Количество;
			СуммаПоПартии = Партия.Сумма;
			Если КоличествоСписать < Партия.Количество Тогда
				КоличествоПоПартии = КоличествоСписать;
				СуммаПоПартии = Партия.Сумма/Партия.Количество*КоличествоПоПартии;
			КонецЕсли; 
			
			СтрокаТМатериалы = ТМатериалы.Добавить();
			ЗаполнитьЗначенияСвойств(СтрокаТМатериалы, СтрокаНоменклатуры);
			СтрокаТМатериалы.Партия = Партия.Партия;
			СтрокаТМатериалы.Количество = КоличествоПоПартии;
			СтрокаТМатериалы.Сумма = СуммаПоПартии;
			
			КоличествоСписать = КоличествоСписать - КоличествоПоПартии;
			
			Если КоличествоПоПартии = Партия.Количество Тогда
				ТПартии.Удалить(Партия);
			Иначе
				Партия.Количество = Партия.Количество - КоличествоПоПартии;
				Партия.Сумма = Партия.Сумма - СуммаПоПартии;
			КонецЕсли;
			
		КонецЦикла; 
		
	КонецЦикла; 
	
	Для Каждого СтрокаНоменклатуры Из ТМатериалы Цикл
		
		Проводка = ПроводкиБУ.Добавить();
		Проводка.Период      = Дата;
		Проводка.Организация = Организация;
		Проводка.Содержание = "";     
		
		Если ИспользоватьЕдиныйСчетЗатрат и Не СписыватьНаРасходыБудущихПериодов Тогда
			Проводка.СчетДт      = СчетЗатрат;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Субконто1);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,Субконто2);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,Субконто3);
		ИначеЕсли Не ИспользоватьЕдиныйСчетЗатрат и Не СписыватьНаРасходыБудущихПериодов Тогда
			Проводка.СчетДт      = СтрокаНоменклатуры.СчетЗатрат;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаНоменклатуры.Субконто1);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СтрокаНоменклатуры.Субконто2);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,СтрокаНоменклатуры.Субконто3);
		Иначе
			Проводка.СчетДт      = ПланыСчетов.Хозрасчетный.А3190;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаНоменклатуры.РасходыБудущихПериодов);
		КонецЕсли; 
		Если СчетЗатрат.Количественный или Проводка.СчетДт.Количественный Тогда
			Проводка.КоличествоДт = СтрокаНоменклатуры.Количество;
		КонецЕсли; 
		
		Проводка.СчетКт     =  СтрокаНоменклатуры.Счет;
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокаНоменклатуры.Номенклатура);
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,2,Склад);
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,3,СтрокаНоменклатуры.Партия);
		Проводка.КоличествоКт = СтрокаНоменклатуры.Количество;
		
		Проводка.Сумма = СтрокаНоменклатуры.Сумма; 
		
		Если СтрокаНоменклатуры.СуммаНДС<>0 Тогда
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			Проводка.Содержание = "";     
			
			Если ИспользоватьЕдиныйСчетЗатрат Тогда
				Проводка.СчетДт      = СчетЗатрат;
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,Субконто1);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,Субконто2);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,Субконто3);
			Иначе
				Проводка.СчетДт      = СтрокаНоменклатуры.СчетЗатрат;
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаНоменклатуры.Субконто1);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СтрокаНоменклатуры.Субконто2);
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,СтрокаНоменклатуры.Субконто3);
			КонецЕсли; 
			Если СчетЗатрат.Количественный Тогда
				Проводка.КоличествоДт = СтрокаНоменклатуры.Количество;
			КонецЕсли; 
			
			Проводка.СчетКт     =  СчетУчетаПлатежа("НДС");
			УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, 1, Справочники.ПлатежиВБюджет.НДС);
			Проводка.Сумма = СтрокаНоменклатуры.СуммаНДС; 
		КонецЕсли; 

		Если Не СписыватьНаРасходыБудущихПериодов Тогда
			Проводка = ПроводкиБУ.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = Организация;
			
			Проводка.СчетДт      = СчетУчетаМатериаловНаЗабалансе(СтрокаНоменклатуры.Счет);
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаНоменклатуры.Номенклатура);
			Если ПолучательВТаблице Тогда
				Проводка.Содержание = ?(Сокрлп(СтрокаНоменклатуры.Требование)="","","Треб. № "+Сокрлп(СтрокаНоменклатуры.Требование));     
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СтрокаНоменклатуры.СкладПолучатель);
			Иначе
				Проводка.Содержание = ?(Сокрлп(Требование)="","","Треб. № "+Сокрлп(Требование));     
				УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СкладПолучатель);
			КонецЕсли;
			УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,СтрокаНоменклатуры.Партия);
			Проводка.КоличествоДт = СтрокаНоменклатуры.Количество;
			
			Проводка.Сумма = СтрокаНоменклатуры.Сумма;
		КонецЕсли;
		
	КонецЦикла; 
	
КонецПроцедуры

// Процедура - обработчик события "ОбработкаПроведения"
//
Процедура ОбработкаПроведения(Отказ, РежимПроведения)

	// Дерево значений, содержащее имена необходимых полей в запросе по шапке.
	Перем ДеревоПолейЗапросаПоШапке;

	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);

	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	//ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента);
	
	Если НЕ Отказ Тогда
		ДвиженияПоРегистрамПоУказаннойСтоимости(РежимПроведения, Отказ, Заголовок, СтруктураШапкиДокумента);
	КонецЕсли;
	
КонецПроцедуры // ОбработкаПроведения()

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры

Процедура ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента)
	
	//Проверяем заполнение шапки
	СтруктураОбязательныхПолей = Новый Структура("Организация");
	СтруктураОбязательныхПолей.Вставить("Склад","Не выбран склад.");  
	Если не ПолучательВТаблице Тогда
		СтруктураОбязательныхПолей.Вставить("СкладПолучатель","Не выбран получатель.");
	КонецЕсли;
	
	Если ИспользоватьЕдиныйСчетЗатрат  Тогда
		СтруктураОбязательныхПолей.Вставить("СчетЗатрат","Не указан счет учета затрат.");
	КонецЕсли;
	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	
	//Проверяем заполнение табличной части 
	
	СтруктураПолей = Новый Структура();
	СтруктураПолей.Вставить("Номенклатура","Не выбрана номенклатура");
	
	СтруктураПолей.Вставить("Счет","Не указан счет учета номенклатуры");
	
	Если НЕ ИспользоватьЕдиныйСчетЗатрат Тогда
		СтруктураПолей.Вставить("СчетЗатрат","Не указан счет учета затрат.");
	КонецЕсли;
	
	Если ПолучательВТаблице Тогда
		СтруктураПолей.Вставить("СкладПолучатель","Не выбран получатель.");
	КонецЕсли;
	
	Если СписыватьНаРасходыБудущихПериодов Тогда
		СтруктураПолей.Вставить("ДатаНачалаСписания","Не указана дата начала списания");
		СтруктураПолей.Вставить("ДатаОкончанияСписания","Не указана дата окончания списания");
		//СтруктураПолей.Вставить("РасходыБудущихПериодов","Не указан элемент ""Расходы будущих периодов""");
	КонецЕсли;
	
	
	
	ПроверитьЗаполнениеТабличнойЧастиПлатежногоДокумента(ЭтотОбъект, "Материалы", СтруктураПолей, Отказ, Заголовок);
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
	Если СписыватьПоУказаннойСтоимости Тогда
		СуммаПоДокументу = Материалы.Итог("Сумма");
	Иначе	
		СуммаПоДокументу = 0;
	КонецЕсли; 
	
	КоличествоПоДокументу=Материалы.Итог("Количество");
	
	ПоказыватьТекущиеОстатки=ложь;
	
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);

	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	
	ПроверитьЗаполнениеДокумента(Отказ, Заголовок, СтруктураШапкиДокумента);
	
КонецПроцедуры


Процедура ПересчитатьТаблицуПоЦенам() Экспорт
	Для каждого Строка Из Материалы Цикл
		Строка.сумма=Строка.Номенклатура.Цена*Строка.Количество;
	КонецЦикла; 
КонецПроцедуры




мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();