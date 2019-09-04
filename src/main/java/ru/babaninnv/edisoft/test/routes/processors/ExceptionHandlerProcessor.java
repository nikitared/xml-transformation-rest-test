package ru.babaninnv.edisoft.test.routes.processors;

import org.apache.camel.Exchange;
import org.apache.camel.Processor;
import org.springframework.stereotype.Component;

@Component
public class ExceptionHandlerProcessor implements Processor {
    @Override
    public void process(Exchange exchange) throws Exception {
        // TODO: добавить логирование на исключение
    }
}
