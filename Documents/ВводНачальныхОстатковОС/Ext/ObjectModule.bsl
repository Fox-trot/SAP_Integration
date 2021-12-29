﻿// Строки, хранят реквизиты имеющие смысл только для бух. учета и упр. соответственно
// в случае если документ не отражается в каком-то виде учета, делаются невидимыми
Перем мСтрокаРеквизитыНалУчета Экспорт; // (Регл)

Перем мУчетнаяПолитика;                 // (Общ)

Перем мВалютаРегламентированногоУчета Экспорт;

Перем мФормаДокумента Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ЭКСПОРТНЫЕ ПРОЦЕДУРЫ И ФУНКЦИИ ДОКУМЕНТА

#Если Клиент Тогда

// Процедура печати табличной части документа
//
Функция ПечатьОписи() Экспорт
	
	Если мФормаДокумента = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	// Список полей, по которым нужно выводить итоги.
	
	
	СписокИтоговыхПолей = Новый СписокЗначений();
	СписокИтоговыхПолей.Добавить("ПервоначальнаяСтоимостьБУ");
	СписокИтоговыхПолей.Добавить("СтоимостьБУ");
	СписокИтоговыхПолей.Добавить("НакопленнаяАмортизацияБУ");
	СписокИтоговыхПолей.Добавить("ПереоценкаБУ");
	
	
	
	
	ТабДок  = Новый ТабличныйДокумент;
	Макет   = ПолучитьМакет("ТабЧасть");
	Область = Макет.ПолучитьОбласть("Заголовок");
	Область.Параметры.Заголовок = Метаданные().Представление() + " № " + Номер + " от " + Формат( Дата, "ДФ=dd.MM.yyyy");
	ТабДок.Вывести( Область);
	
	Область = Макет.ПолучитьОбласть("ШапкаБух");
	Область.Параметры.Организация              = Организация;
	ТабДок.Вывести( Область);
	
	// Создадим структуру печатаемых реквизитов
	МетаТЧ     = Метаданные().ТабличныеЧасти.ОС.Реквизиты;
	СтруктРекв = Новый Структура;
	СтруктРекв.Вставить("ОсновноеСредство", МетаТЧ.ОсновноеСредство);
	Для Каждого Колонка Из мФормаДокумента.ЭлементыФормы.ОС.Колонки Цикл
		Если Не (Колонка.Имя = "НомерСтроки" ИЛИ Колонка.Имя = "КодОС")
			   И Колонка.Видимость Тогда
			СтруктРекв.Вставить( Колонка.Имя, МетаТЧ[Колонка.Имя]);
		КонецЕсли;
	КонецЦикла;
	
	// Вывод заголовка таб части
	Область = Макет.ПолучитьОбласть( "ТабШапка|Начало");
	ТабДок.Вывести( Область);
	Область = Макет.ПолучитьОбласть( "ТабШапка|Колонка");
	Для Каждого Колонка Из СтруктРекв Цикл
		Если Не Колонка.Ключ = "ОсновноеСредство" Тогда
			Область.Параметры.КолЗаголовок = Колонка.Значение;
			ТабДок.Присоединить(Область);
		КонецЕсли;
	КонецЦикла;
	
	// Вывод данных
	Для Каждого СтрокаТЧ Из ОС Цикл
		Область = Макет.ПолучитьОбласть( "ТабСтрока|Начало");
		Область.Параметры.НомерСтроки = СтрокаТЧ.НомерСтроки;
		Область.Параметры.ОС          = СтрокаТЧ.ОсновноеСредство;
		ТабДок.Вывести( Область);
		
		Область = Макет.ПолучитьОбласть( "ТабСтрока|Колонка");
		Для Каждого Колонка Из СтруктРекв Цикл
			
			//Если не Колонки[Колонка.Ключ].Видимость Тогда
			//	Продолжить;
			//КонецЕсли; 
			
			Если Не Колонка.Ключ = "ОсновноеСредство" Тогда
				Область.Параметры.КолДанные = СтрокаТЧ[Колонка.Ключ];
				Если ТипЗнч(СтрокаТЧ[Колонка.Ключ]) = Тип("Булево") Тогда
					Область.ТекущаяОбласть.Формат = "БЛ=Нет; БИ=Да";
				ИначеЕсли ТипЗнч(СтрокаТЧ[Колонка.Ключ]) = Тип("Дата") Тогда
					Область.ТекущаяОбласть.Формат = "ДЛФ=DD";
				ИначеЕсли ТипЗнч(СтрокаТЧ[Колонка.Ключ]) = Тип("Число") Тогда
					//Формат числового значения
					Разрядность = 0;
					РазрядностьДробнойЧасти = 0;
					Если Колонка.Значение.Тип.СодержитТип(Тип("Число")) тогда
						Разрядность = Колонка.Значение.Тип.КвалификаторыЧисла.Разрядность;
						РазрядностьДробнойЧасти = Колонка.Значение.Тип.КвалификаторыЧисла.РазрядностьДробнойЧасти;
					КонецЕсли;
					СтрокаФормата = ?(Разрядность=0,"","ЧЦ="+Разрядность+";")+?(РазрядностьДробнойЧасти=0,"","ЧДЦ="+РазрядностьДробнойЧасти);				
					
					Область.ТекущаяОбласть.Формат = СтрокаФормата;
				КонецЕсли;
				ТабДок.Присоединить(Область);
			КонецЕсли;
		КонецЦикла;
		
	КонецЦикла;
	
	// Вывод итогов
	Область = Макет.ПолучитьОбласть( "ТабИтог|Начало");
	ТабДок.Вывести( Область);
	
	Область = Макет.ПолучитьОбласть( "ТабИтог|Колонка");
	Для Каждого Колонка Из СтруктРекв Цикл
		Если Колонка.Ключ = "ОсновноеСредство" Тогда
			Продолжить;
		КонецЕсли;
		Если Колонка.Значение.Тип.Типы()[0] = Тип("Число") 
		   И НЕ (СписокИтоговыхПолей.НайтиПоЗначению(Колонка.Ключ) = Неопределено) Тогда
			//Формат числового значения
			РазрядностьДробнойЧасти = Колонка.Значение.Тип.КвалификаторыЧисла.РазрядностьДробнойЧасти;
			СтрокаФормата = ?(РазрядностьДробнойЧасти=0,"","ЧДЦ="+РазрядностьДробнойЧасти+";");				
			Область.Параметры.КолИтог = ОС.Итог( Колонка.Ключ);
			Область.ТекущаяОбласть.Формат = СтрокаФормата+"ЧРД=,; ЧРГ=; ЧГ=3,0";
		Иначе
			Область.Параметры.КолИтог = "";
		КонецЕсли;
		ТабДок.Присоединить(Область);
	КонецЦикла;
	
	ТабДок.ТолькоПросмотр      = Истина;
	ТабДок.ОтображатьСетку     = Ложь;
	ТабДок.ОтображатьЗаголовки = Ложь;
	Возврат ТабДок;
	
КонецФункции 

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
	
	Если ИмяМакета = "Опись" Тогда
		// Получить экземпляр документа на печать
		ТабДокумент = ПечатьОписи();
		
	КонецЕсли;
	
	НапечататьДокумент(ТабДокумент, КоличествоЭкземпляров, НаПринтер, СформироватьЗаголовокДокумента(ЭтотОбъект), НепосредственнаяПечать);
	
КонецПроцедуры // Печать

#КонецЕсли

// Возвращает доступные варианты печати документа
//
// Вовращаемое значение:
//  Струткура, каждая строка которой соответствует одному из вариантов печати
//  
Функция ПолучитьСтруктуруПечатныхФорм() Экспорт
	
	Возврат Новый Структура("Опись","Опись ОС при вводе остатков");

КонецФункции // ПолучитьСтруктуруПечатныхФорм()

// Процедура заполняет структуры именами реквизитов, которые имеют смысл
// только для определенного вида учета
//
Процедура ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчета() Экспорт
	
	
КонецПроцедуры // ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчета()


////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ДЛЯ ОБЕСПЕЧЕНИЯ ПРОВЕДЕНИЯ ДОКУМЕНТА

// Процедура проверяет корректность заполнения реквизитов шапки документа
//
Процедура ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок)
	
	СтруктураОбязательныхПолей = Новый Структура("Организация");

	ПроверитьЗаполнениеШапкиДокумента(ЭтотОбъект, СтруктураОбязательныхПолей, Отказ, Заголовок);
	
	
	СтруктураПолей = Новый Структура();
	
	СтруктураПолей.Вставить("ОсновноеСредство","Не выбрано основное средство");
	
	ПроверитьЗаполнениеТабличнойЧастиПлатежногоДокумента(ЭтотОбъект, "ОС", СтруктураПолей, Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеШапки()

// Процедура проверяет корректность заполнения реквизитов таб. части документа
//
Процедура ПроверитьЗаполнениеТабЧасти(СтруктураШапкиДокумента, Отказ, Заголовок);

	ОбязательныеРеквизиты = "ОсновноеСредство,МОЛ,Подразделение";
	
	ОбязательныеРеквизиты =ОбязательныеРеквизиты+",СчетУчетаБУ,СчетАмортизацииБУ";
	
	ПроверитьЗаполнениеТабличнойЧасти(ЭтотОбъект, "ОС", Новый Структура(ОбязательныеРеквизиты), Отказ, Заголовок);

КонецПроцедуры // ПроверитьЗаполнениеТабЧасти()

// Процедура формирования движений по регистру Первоначальные сведеняи об ОС бух.
//
Процедура ДвижениеПоРегиструПервоначальныеСведенияОСБух(ТабОС, СтруктураШапкиДокумента)
		
	НаборДвижений   = Движения.ПервоначальныеСведенияОСБухгалтерскийУчет;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период                      = СтрокаОС.ДатаВводаВЭксплуатацию;
		НоваяСтрока.Организация                 = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.ОсновноеСредство            = СтрокаОС.ОсновноеСредство;
		//НоваяСтрока.ИнвентарныйНомер            = СтрокаОС.ИнвентарныйНомер;
		НоваяСтрока.СпособПоступления			= СтрокаОС.СпособПоступления;
		НоваяСтрока.ПервоначальнаяСтоимость     = СтрокаОС.ПервоначальнаяСтоимостьБУ;
		НоваяСтрока.СпособНачисленияАмортизации = СтрокаОС.СпособНачисленияАмортизации;
		НоваяСтрока.ПорядокПогашенияСтоимости   = Перечисления.ПорядокПогашенияСтоимостиОС.НачислениеАмортизации;
		//НоваяСтрока.ПроизводственнаяГруппа      = СтрокаОС.ПроизводственнаяГруппа;
		НоваяСтрока.ПротивопожарныеОС           = СтрокаОС.Противопожарные;
		НоваяСтрока.ОСПоОхранеОкружающейСреды   = СтрокаОС.ОСПоОхранеОкружающейСреды;
		НоваяСтрока.Состояние          			= СтрокаОС.Состояние;
		НоваяСтрока.ГруппаОборудования          = СтрокаОС.ГруппаОборудования;
		НоваяСтрока.ГруппаОС                    = СтрокаОС.ГруппаОС;
	КонецЦикла;
	
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры // ДвижениеПоРегиструПервоначальныеСведенияОСБух()

// Процедура формирования движений по регистру Местонахождение ОС бух.
//
Процедура ДвижениеПоРегиструМестонахождениеОСБух( ТабОС, СтруктураШапкиДокумента)
		
	НаборДвижений   = Движения.МестонахождениеОСБухгалтерскийУчет;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период           = СтрокаОС.ДатаВводаВЭксплуатацию;
		НоваяСтрока.Организация      = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.ОсновноеСредство = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.МОЛ              = СтрокаОС.МОЛ;
		НоваяСтрока.Местонахождение  = СтрокаОС.Подразделение;
		НоваяСтрока.МестонахождениеОСДляГНИ = СтрокаОС.МестонахождениеОСДляГНИ;
	КонецЦикла;
	
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры // ДвижениеПоРегиструМестонахождениеОСБух()

////////////////////////////////////////////////////////////////////////////////

// Процедура формирования движений по регистру Начисление амортизации бух.
//
Процедура ДвижениеПоРегиструНачислениеАмортизацииБух( ТабОС, СтруктураШапкиДокумента, Заголовок)
		
	НаборДвижений   = Движения.НачислениеАмортизацииОСБухгалтерскийУчет;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период               = СтрокаОС.ДатаВводаВЭксплуатацию;
		НоваяСтрока.Организация          = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.ОсновноеСредство     = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.НачислятьАмортизацию = СтрокаОС.НачислятьАмортизациюБУ;
		
	КонецЦикла;
	
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры // ДвижениеПоРегиструНачислениеАмортизацииБух()


// Процедура формирования движений по регистру ПараметрыАмортизации ОС бух.
//
Процедура ДвижениеПоРегиструПараметрыАмортизацииБух( ТабОС, СтруктураШапкиДокумента)
		
	НаборДвижений   = Движения.ПараметрыАмортизацииОСБухгалтерскийУчет;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		ДатаДвижения = СтрокаОС.ДатаВводаВЭксплуатацию;
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период           = ДатаДвижения;
		НоваяСтрока.Организация      = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.ОсновноеСредство = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.СтоимостьДляВычисленияАмортизации           = СтрокаОС.СтоимостьБУ;
		НоваяСтрока.КоэффициентАмортизации                      = СтрокаОС.КоэффициентАмортизацииБУ;
		НоваяСтрока.КорректирующийКоэффициент                   = СтрокаОС.КорректирующийКоэффициент;
		НоваяСтрока.ПараметрВыработкиОС                         = СтрокаОС.ПараметрВыработкиОС;
		
	КонецЦикла;
	
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры // ДвижениеПоРегиструПараметрыАмортизацииБух()
////////////////////////////////////////////////////////////////////////////////

// Процедура формирования движений по регистру Состояния ОС бух.
//
Процедура ДвижениеПоРегиструСостоянияОСБух( ТабОС, СтруктураШапкиДокумента,Отказ,Заголовок)
		
	НаборДвижений   = Движения.СостоянияОСОрганизацийБухгалтерскийУчет;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.ДатаСостояния     = СтрокаОС.ДатаВводаВЭксплуатацию;
		НоваяСтрока.ОсновноеСредство  = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.Организация       = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.Состояние         = Перечисления.СостоянияОС.ПринятоКУчету;
		
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.ДатаСостояния     = СтрокаОС.ДатаВводаВЭксплуатацию;
		НоваяСтрока.ОсновноеСредство  = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.Организация       = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.Состояние         = Перечисления.СостоянияОС.ВведеноВЭксплуатацию;
		
	КонецЦикла;
	ПроверкаДублированияЗаписейСостоянийОС(СтруктураШапкиДокумента.Организация, ТаблицаДвижений,Отказ,Заголовок);
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры // ДвижениеПоРегиструМестонахождениеОСБух()

// Процедура формирования движений по регистру Состояния ОС бух.
//
Процедура ДвижениеПоРегиструОперацииОСБух( ТабОС, СтруктураШапкиДокумента)
		
	НаборДвижений   = Движения.СобытияОСОрганизацийБухгалтерскийУчет;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период            = СтрокаОС.ДатаВводаВЭксплуатацию;
		НоваяСтрока.ОсновноеСредство  = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.Организация       = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.Событие           = СтрокаОС.СостояниеВводаВЭксплуатацию;
		НоваяСтрока.НомерДокумента    = СтрокаОС.НомерДокументаВводаВЭксплуатацию;
		НоваяСтрока.НазваниеДокумента = СтрокаОС.НазваниеДокументаВводаВЭксплуатацию;
		
	КонецЦикла;
	
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры // ДвижениеПоРегиструМестонахождениеОСБух()
////////////////////////////////////////////////////////////////////////////////

Процедура ДвижениеПоРегиструСпособыОтраженияБух	     ( ТабОС, СтруктураШапкиДокумента, Заголовок)
		
	НаборДвижений   = Движения.СпособыОтраженияРасходовПоАмортизацииОСБухгалтерскийУчет;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		Если ЗначениеНеЗаполнено(СтрокаОС.СпособОтраженияРасходовПоАмортизации) тогда
			Продолжить;
		КонецЕслИ;
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период            = СтрокаОС.ДатаВводаВЭксплуатацию;
		НоваяСтрока.ОсновноеСредство  = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.Организация       = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.СпособыОтраженияРасходовПоАмортизации = СтрокаОС.СпособОтраженияРасходовПоАмортизации;
		НоваяСтрока.ШифрПроизводственныхЗатрат = СтрокаОС.ШифрПроизводственныхЗатрат;
		
	КонецЦикла;
	
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры // ДвижениеПоРегиструСпособыОтраженияБух()

// Процедура формирования движений по регистру СчетаУчета ОС бух.
//
Процедура ДвижениеПоРегиструСчетовУчетаОСБух( ТабОС, СтруктураШапкиДокумента)
		
	НаборДвижений   = Движения.СчетаБухгалтерскогоУчетаОС;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период     		  = СтрокаОС.ДатаВводаВЭксплуатацию;
		НоваяСтрока.ОсновноеСредство  = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.Организация       = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.СчетУчета         = СтрокаОС.СчетУчетаБУ;
		НоваяСтрока.СчетНачисленияАмортизации = СтрокаОС.СчетАмортизацииБУ;
		
	КонецЦикла;
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры // ДвижениеПоРегиструСчетовУчетаОСБух()

Процедура ДвижениеПоРегиструЛьготныеОС( ТабОС, СтруктураШапкиДокумента)
		
	НаборДвижений   = Движения.ЛьготныеОсновныеСредства;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период               = СтрокаОС.ДатаВводаВЭксплуатацию;
		НоваяСтрока.Организация          = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.ОсновноеСредство     = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.Льгота               = СтрокаОС.Льгота;
		
	КонецЦикла;
	
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры
////////////////////////////////////////////////////////////////////////////////

Процедура ДвижениеПоРегиструЛизинговыеОС( ТабОС, СтруктураШапкиДокумента)
		
	НаборДвижений   = Движения.ЛизинговыеОсновныеСредства;
	ТаблицаДвижений = НаборДвижений.Выгрузить();
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		НоваяСтрока = ТаблицаДвижений.Добавить();
		НоваяСтрока.Период               = СтрокаОС.ДатаВводаВЭксплуатацию;
		НоваяСтрока.Организация          = СтруктураШапкиДокумента.Организация;
		НоваяСтрока.ОсновноеСредство     = СтрокаОС.ОсновноеСредство;
		НоваяСтрока.Лизинг               = СтрокаОС.Лизинг;
		НоваяСтрока.СрокМесяцев          = СтрокаОС.ЛизингСрокМесяцев;
		
	КонецЦикла;
	
	НаборДвижений.Загрузить(ТаблицаДвижений);
	НаборДвижений.УстановитьАктивность(Истина);
	
КонецПроцедуры // ДвижениеПоРегиструНачислениеАмортизацииБух()
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Процедура формирование проводок.
//
Процедура ФормированиеПроводокБух(ТабОС, СтруктураШапкиДокумента)
	
	Операция = Движения.Хозрасчетный;
	
	Для Каждого СтрокаОС Из ТабОС Цикл
		
		ОсновноеСредствоОбъект=СтрокаОС.ОсновноеСредство.ПолучитьОбъект();
		ОсновноеСредствоОбъект.ИнвентарныйНомер=СтрокаОС.ИнвентарныйНомер;
		ОсновноеСредствоОбъект.Записать();
		
		
		Если НЕ ЗначениеНеЗаполнено(СтрокаОС.СчетУчетаБУ) Тогда
			// Ввод балансовой стоимости ОС.
			Проводка = Операция.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = СтруктураШапкиДокумента.Организация;
			Проводка.Содержание  = "Ввод остатков по ОС (баланс. стоимость)";
			Проводка.Сумма       = СтрокаОС.СтоимостьБУ;
			
			Проводка.СчетДт = СтрокаОС.СчетУчетаБУ;
			УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, "ОсновныеСредства", СтрокаОС.ОсновноеСредство);
			УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, "Подразделения", СтрокаОС.Подразделение);
			УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, "МОЛ", СтрокаОС.МОЛ);
			УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, "ГруппыОС", СтрокаОС.ГруппаОС);
			
			Если СчетИсточник.Пустая() Тогда
				Проводка.СчетКт = ПланыСчетов.Хозрасчетный.Вспомогательный;
			Иначе
				Проводка.СчетКт = СчетИсточник;
				УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, 1, Субконто1);
				УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, 2, Субконто2);
				УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, 2, Субконто3);
			КонецЕсли; 
		КонецЕсли;
		
		Если НЕ ЗначениеНеЗаполнено(СтрокаОС.СчетАмортизацииБУ) И НЕ (СтрокаОС.НакопленнаяАмортизацияБУ = 0) Тогда
			// Ввод начисленной амортизации.
			Проводка = Операция.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = СтруктураШапкиДокумента.Организация;
			Проводка.Содержание  = "Ввод остатков по ОС (начисл. амортизация)";
			Проводка.Сумма       = СтрокаОС.НакопленнаяАмортизацияБУ;
			
			Если СчетИсточник.Пустая() Тогда
				Проводка.СчетДт = ПланыСчетов.Хозрасчетный.Вспомогательный;
			Иначе
				Проводка.СчетДт = СчетИсточник;
				УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 1, Субконто1);
				УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 2, Субконто2);
				УстановитьСубконто(Проводка.СчетДт, Проводка.СубконтоДт, 2, Субконто3);
			КонецЕсли; 
			
			Проводка.СчетКт = СтрокаОС.СчетАмортизацииБУ;
			УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, "ОсновныеСредства", СтрокаОС.ОсновноеСредство);
			УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, "Подразделения", СтрокаОС.Подразделение);
			УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, "МОЛ", СтрокаОС.МОЛ);
			УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, "ГруппыОС", СтрокаОС.ГруппаОС);
		КонецЕсли;
		
		Если НЕ (СтрокаОС.ПереоценкаБУ = 0) Тогда
			// Ввод начисленной амортизации.
			Проводка = Операция.Добавить();
			Проводка.Период      = Дата;
			Проводка.Организация = СтруктураШапкиДокумента.Организация;
			Проводка.Содержание  = "Ввод остатков по ОС (переоценка)";
			Проводка.Сумма       = СтрокаОС.ПереоценкаБУ;
			
			Проводка.СчетДт = ПланыСчетов.Хозрасчетный.Вспомогательный;
			
			Проводка.СчетКт = ПланыСчетов.Хозрасчетный.А8510;
			УстановитьСубконто(Проводка.СчетКт, Проводка.СубконтоКт, "ОсновныеСредства", СтрокаОС.ОсновноеСредство);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры // ФормированиеПроводокБух
////////////////////////////////////////////////////////////////////////////////

// Процедура формирования движений по регистрам.
//
Процедура ДвиженияПоРегистрам(СтруктураШапкиДокумента, Отказ,Заголовок)

	ТабОС = ОС.Выгрузить();

	ДвижениеПоРегиструПервоначальныеСведенияОСБух( ТабОС, СтруктураШапкиДокумента);
	ДвижениеПоРегиструСостоянияОСБух             ( ТабОС, СтруктураШапкиДокумента,Отказ,  Заголовок);
	ДвижениеПоРегиструМестонахождениеОСБух       ( ТабОС, СтруктураШапкиДокумента);
	ДвижениеПоРегиструНачислениеАмортизацииБух   ( ТабОС, СтруктураШапкиДокумента, Заголовок);
	ДвижениеПоРегиструПараметрыАмортизацииБух    ( ТабОС, СтруктураШапкиДокумента);
	ДвижениеПоРегиструСпособыОтраженияБух	     ( ТабОС, СтруктураШапкиДокумента, Заголовок);
	ДвижениеПоРегиструОперацииОСБух              ( ТабОС, СтруктураШапкиДокумента);
	ДвижениеПоРегиструСчетовУчетаОСБух           ( ТабОС, СтруктураШапкиДокумента);
	ДвижениеПоРегиструЛьготныеОС                 ( ТабОС, СтруктураШапкиДокумента);
	ДвижениеПоРегиструЛизинговыеОС               ( ТабОС, СтруктураШапкиДокумента);
	
	Если не СчетИсточник.Пустая() Тогда
		
		ФормированиеПроводокБух( ТабОС, СтруктураШапкиДокумента);
		
	Иначе	
		
		Сообщить("Не заполнен ""Счет источник"", бухгалтерские проводки не сформированы!");
		
	КонецЕсли; 
	
	
	
КонецПроцедуры // ДвиженияПоРегистрам()

////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ

Процедура ОшибкаПроведенияПоСтроке(СтрокаОС, ТекстСообщения,Заголовок,Статус)
	НачалоСообщения = "- строка № "+СтрокаОС.НомерСтроки+", инв. номер ОС <"+СтрокаОС.ОсновноеСредство.ИнвентарныйНомер+"> : ";
	СообщитьОбОшибке(НачалоСообщения+ТекстСообщения, ,Заголовок ,Статус)
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ)

	Заголовок = ПредставлениеДокументаПриПроведении(Ссылка);
	
	ЗаполнитьСписокРеквизитовЗависимыхОтТиповУчета();

	// Сформируем запрос на дополнительные параметры, нужные при проведении, по данным шапки документа
	СтруктураШапкиДокумента = СформироватьСтруктуруШапкиДокумента(ЭтотОбъект);

	// Проверим правильность заполнения шапки документа
	ПроверитьЗаполнениеШапки(СтруктураШапкиДокумента, Отказ, Заголовок);
	//ПроверитьЗаполнениеТабЧасти(СтруктураШапкиДокумента, Отказ, Заголовок);
	
	СтруктураПолей = Новый Структура;
	СтруктураПолей.Вставить("ОсновноеСредство", "ОсновноеСредство");
	СтруктураПолей.Вставить("НомерСтроки",      "НомерСтроки");
	//СтруктураПолей.Вставить("ИнвентарныйНомер", "ИнвентарныйНомер");

	РезультатЗапросаПоОС = СформироватьЗапросПоТабличнойЧасти(ЭтотОбъект, "ОС", СтруктураПолей);
	ТаблицаПоОС          = РезультатЗапросаПоОС.Выгрузить();
	
	// Проверим, нет ли повторяющихся основных средств в таблице по ОС.
	ПроверитьДублиОС(ТаблицаПоОС, Отказ, Заголовок);

	// Проверим, нет ли одинаковых инвентарных номеров основных средств в таблице по ОС.
	//ПроверитьДублиИнвентарныхНомеровОС(ТаблицаПоОС, Отказ, Заголовок);
	
	Если НЕ Отказ Тогда
		
		ДвиженияПоРегистрам(СтруктураШапкиДокумента, Отказ, Заголовок);
		
	КонецЕсли;
	
КонецПроцедуры // ОбработкаПроведения()

Процедура ПоменятьДаты() Экспорт
	
	Для каждого СтрокаОС Из ОС Цикл
		
		ДатаС=СтрокаОС.ДатаВводаВЭксплуатацию;
		
		СтрокаОС.ДатаВводаВЭксплуатацию=Дата(Год(ДатаС),день(ДатаС),1);
		
	КонецЦикла; 
	
КонецПроцедуры
 

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	ДобавитьПрефиксУзла(Префикс);
КонецПроцедуры


мВалютаРегламентированногоУчета = Константы.ВалютаРегламентированногоУчета.Получить();
мФормаДокумента = Неопределено;