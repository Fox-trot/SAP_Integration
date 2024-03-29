﻿
Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	
	ДобавитьПрефиксУзла(Префикс);
	
КонецПроцедуры

Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("","");
	
КонецФункции

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	
	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);
	
	ДвиженияПоРасчетнымРегистрам();
	
	ДвиженияПоБУ();
	
КонецПроцедуры

Процедура ДвиженияПоБУ()
	
	тз=новый ТаблицаЗначений;
	тз.Колонки.Добавить("ВидРасчета");
	тз.Колонки.Добавить("Сотрудник");
	тз.Колонки.Добавить("СпособОтраженияРасходов");
	тз.Колонки.Добавить("НЕПроводить");
	тз.Колонки.Добавить("Сумма",Новый ОписаниеТипов(Новый КвалификаторыЧисла(15,2)));
	
	Для Каждого ТекСтрокаРасчеты Из Расчеты Цикл
		
		СпособОтраженияРасходов = ТекСтрокаРасчеты.СпособОтраженияРасходов;
		
		Для н=1 По СписокНачислений.Количество() Цикл
			
			ВидРасчета=СписокНачислений[н-1].ВидРасчета;
					
			//Если ВходитВГруппуНачислений(ВидРасчета,Справочники.ГруппыНачислений.ПрочиеДоходы) Тогда
			//	Продолжить;
			//КонецЕсли; 
			
			Результат=0;
			
			Если ТекСтрокаРасчеты["н"+Строка(н)]<>0 Тогда
				
				Результат=ТекСтрокаРасчеты["н"+Строка(н)];
				
			КонецЕсли; 
			
			Если Результат<>0 Тогда
				
				СтрокаТз = тз.Добавить();
				СтрокаТз.ВидРасчета = ВидРасчета;
				Если ВидРасчета.ОсобыйСпособОтраженияРасходовБУ Тогда
					СтрокаТз.СпособОтраженияРасходов =ВидРасчета.СпособОтраженияРасходовБУ;
				Иначе	
					СтрокаТз.СпособОтраженияРасходов = СпособОтраженияРасходов;
				КонецЕсли; 
				СтрокаТз.Сотрудник = ТекСтрокаРасчеты.Сотрудник;
				СтрокаТз.Сумма = Результат;
				СтрокаТз.НЕПроводить = ВидРасчета.НеПроводить;
				Если ВходитВГруппуНачислений(ВидРасчета,Справочники.ГруппыНачислений.ПрочиеДоходы) Тогда
					СтрокаТз.НЕПроводить=истина;
				КонецЕсли; 
				
			КонецЕсли; 
			
		КонецЦикла; 
		
		
	КонецЦикла;
	
	ТаблицаПоВР=тз.Скопировать();
	
	тз.Свернуть("сотрудник,СпособОтраженияРасходов,НЕПроводить","Сумма");
	ТаблицаПоВР.Свернуть("ВидРасчета,СпособОтраженияРасходов","Сумма");
	
	
	Для каждого СтрокаТз Из Тз Цикл
		
		Если СтрокаТз.НеПроводить Тогда
			Продолжить;
		КонецЕсли;
		
		Проводка = Движения.Хозрасчетный.Добавить();
		Проводка.Период      = Дата;
		Проводка.Организация = Организация;
		Проводка.Содержание = "";     
		
		Проводка.СчетДт      = СтрокаТз.СпособОтраженияРасходов.Счет;
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаТз.СпособОтраженияРасходов.Субконто1);
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СтрокаТз.СпособОтраженияРасходов.Субконто2);
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,СтрокаТз.СпособОтраженияРасходов.Субконто3);
		
		Проводка.СчетКт     =  ПланыСчетов.Хозрасчетный.НайтиПоКоду("6710");
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,СтрокаТз.Сотрудник);
		
		Проводка.Сумма=СтрокаТз.Сумма;
	КонецЦикла; 
	
	ЕСН=Справочники.ПлатежиВБюджет.ЕСН;
	СтавкаЕСН=СтавкаПлатежа("ЕСН",КонецМесяца(Дата));
	
	ОблагаетсяПФ=Справочники.ГруппыНачислений.ОблагаетсяПенсионнымиВзносами;
	
	Для каждого СтрокаТз Из ТаблицаПоВР Цикл
		
		Если не ВходитВГруппуНачислений(СтрокаТз.ВидРасчета,ОблагаетсяПФ) Тогда
			СтрокаТз.Сумма= 0;
		Иначе
			СтрокаТз.Сумма= окр(СтрокаТз.Сумма*СтавкаЕСН/100,2);
		КонецЕсли;	
	КонецЦикла; 
	
	ТаблицаПоВР.Свернуть("СпособОтраженияРасходов","Сумма");
		
	Для каждого СтрокаТз Из ТаблицаПоВР Цикл
		
		Если СтрокаТз.Сумма =0 Тогда продолжить КонецЕсли;
		
		Проводка = Движения.Хозрасчетный.Добавить();
		Проводка.Период      = Дата;
		Проводка.Организация = Организация;
		Проводка.Содержание = "";     
		
		Проводка.СчетДт      = СтрокаТз.СпособОтраженияРасходов.СчетСоцстрах;
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,1,СтрокаТз.СпособОтраженияРасходов.СубконтоСоцстрах1);
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,2,СтрокаТз.СпособОтраженияРасходов.СубконтоСоцстрах2);
		УстановитьСубконто(Проводка.СчетДт,Проводка.СубконтоДт,3,СтрокаТз.СпособОтраженияРасходов.СубконтоСоцстрах3);
		
		Проводка.СчетКт     =  ЕСН.СчетУчета;
		УстановитьСубконто(Проводка.СчетКт,Проводка.СубконтоКт,1,ЕСН);
		
		Проводка.Сумма=СтрокаТз.Сумма;
	КонецЦикла; 
	
	
КонецПроцедуры

Процедура ДвиженияПоРасчетнымРегистрам()
	
	Если Подразделение.Пустая() Тогда
		Запрос=новый Запрос;
		Запрос.Текст=
		"ВЫБРАТЬ
		|	РаботникиОрганизацийСрезПоследних.Сотрудник,
		|	РаботникиОрганизацийСрезПоследних.ПодразделениеОрганизации
		|ИЗ
		|	РегистрСведений.РаботникиОрганизаций.СрезПоследних(
		|			&КонецПериода,
		|			Организация = &Организация
		|				И Сотрудник В (&СписокСотрудников)) КАК РаботникиОрганизацийСрезПоследних";
		
		Запрос.УстановитьПараметр("КонецПериода",КонецМесяца(Дата));
		Запрос.УстановитьПараметр("Организация",Организация);
		Запрос.УстановитьПараметр("СписокСотрудников",Расчеты.ВыгрузитьКолонку("Сотрудник"));
		
		СведенияОПодразделениях=Запрос.Выполнить().Выгрузить();
	КонецЕсли;
	
	НТП=НачалоМесяца(Дата);
	КТП=КонецМесяца(Дата);
	
	
	Для Каждого ТекСтрокаРасчеты Из Расчеты Цикл
		
		Дни=ТекСтрокаРасчеты.Дни;
		Часы=ТекСтрокаРасчеты.Часы;
		
		Для н=1 По СписокНачислений.Количество() Цикл
			
			ВидРасчета=СписокНачислений[н-1].ВидРасчета;
			Результат=0;
			
			Если ТекСтрокаРасчеты["н"+Строка(н)]<>0 Тогда
				
				Результат=ТекСтрокаРасчеты["н"+Строка(н)];
				
			КонецЕсли; 
			
			Если Результат<>0 Тогда
				
				Движение = Движения.Начисления.Добавить();
				Движение.Сторно = Ложь;
				Движение.ВидРасчета = ВидРасчета;
				Движение.ПериодРегистрации = Дата;
				Движение.Организация = Организация;
				Движение.Сотрудник = ТекСтрокаРасчеты.Сотрудник;
				Движение.Результат = Результат;
				Движение.Дни = Дни;
				Движение.Часы = Часы;
				Движение.ДатаНачала = НТП;
				Движение.ДатаОкончания = КТП;
				
				Если ВидРасчета=ПланыВидовРасчета.Начисления.ДоплатаЗаСверхурочныеЧасы Тогда
					Движение.Дни = 0;
					Движение.Часы = ТекСтрокаРасчеты.СверхурочныеЧасы;
				ИначеЕсли ВидРасчета=ПланыВидовРасчета.Начисления.ДоплатаЗаНочныеЧасы Тогда
					Движение.Дни = 0;
					Движение.Часы = ТекСтрокаРасчеты.НочныеЧасы;
				ИначеЕсли ВидРасчета=ПланыВидовРасчета.Начисления.ДоплатаЗаРаботуВПраздник Тогда
					Движение.Дни = ТекСтрокаРасчеты.ПраздничныеДни;
					Движение.Часы = 0;
				КонецЕсли;	
				
				Если Подразделение.Пустая() Тогда
					СведенияОПодразделении=СведенияОПодразделениях.Найти(ТекСтрокаРасчеты.Сотрудник);
					
					Если СведенияОПодразделении=Неопределено Тогда
						Сообщить("Нет данных о подразделении сотрудника "+ТекСтрокаРасчеты.Сотрудник.Наименование+" таб.№ "+ТекСтрокаРасчеты.Сотрудник.Код,СтатусСообщения.Важное);
						Отказ=истина;
					Иначе
						Движение.Подразделение = СведенияОПодразделении.ПодразделениеОрганизации;
					КонецЕсли;
				Иначе
					Движение.Подразделение = Подразделение;
				КонецЕсли;
				
				Дни=0;
				Часы=0;
				
			КонецЕсли; 
			
		КонецЦикла; 
		
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПечатьДокумента(ИмяМакета)
	ТабДок = Новый ТабличныйДокумент;
	
	//Макет = ПолучитьОбщийМакет(ИмяМакета);
	
	//Руководители = ОтветственныеЛица(Организация, Дата);	
	//Область.Параметры.Заполнить(Руководители);
	//Область = Макет.ПолучитьОбласть("ПП");
	//Область.Параметры.Номер = ПолучитьНомерНаПечать(ЭтотОбъект);
	
	//ТабДок.Вывести(Область);
	//ТабДок.ФиксацияСверху=0;
	//ТабДок.ФиксацияСлева=0;
	//ТабДок.ЭкземпляровНаСтранице=0;
	//ТабДок.ТолькоПросмотр = Истина;
	
	Возврат ТабДок;
КонецФункции

Процедура Печать(ИмяМакета, КоличествоЭкземпляров = 1, НаПринтер = Ложь, НепосредственнаяПечать = Ложь) Экспорт
	
	// Получить экземпляр документа на печать
	
	ТабДокумент = ПечатьДокумента(ИмяМакета);
		
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, "");
	
КонецПроцедуры // Печать()

