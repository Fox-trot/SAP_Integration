﻿
&НаКлиенте
Процедура НеВычетаемыеРасходыВключаемыеНОБПриИзменении(Элемент)
	Установитьвидимость();
КонецПроцедуры

&НаКлиенте
Процедура Установитьвидимость()
	Элементы.СтрокаПриложения3.Видимость = Запись.НеВычетаемыеРасходыВключаемыеНОБ;
	Элементы.СтрокаПриложения4.Видимость = Запись.НеВычетаемыеРасходыВключаемыеНОБОтчетногоПериода;
	Элементы.СтрокаПриложения7.Видимость = Запись.УменьшениеНОБ;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Установитьвидимость();
КонецПроцедуры

&НаКлиенте
Процедура НеВычетаемыеРасходыВключаемыеНОБОтчетногоПериодаПриИзменении(Элемент)
	Установитьвидимость();
КонецПроцедуры

&НаКлиенте
Процедура УменьшениеНОБПриИзменении(Элемент)
	Установитьвидимость();
КонецПроцедуры
