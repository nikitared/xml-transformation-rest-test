package ru.babaninnv.edisoft.test.routes;

import org.apache.camel.spring.SpringRouteBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import ru.babaninnv.edisoft.test.routes.processors.ExceptionHandlerProcessor;
import ru.babaninnv.edisoft.test.routes.processors.XmlFilePersistProcessor;

import javax.xml.transform.TransformerException;

/**
 * Роутер для обработки файлов расположенных в директории {@code client.input.folder}
 *
 * @author Nikita Babanin
 * @version 1.0
 */
@Component
public class XsltRouter extends SpringRouteBuilder {

    private final XmlFilePersistProcessor xmlFilePersistProcessor;

    private final ExceptionHandlerProcessor exceptionHandlerProcessor;


    @Autowired
    public XsltRouter(XmlFilePersistProcessor xmlFilePersistProcessor,
            ExceptionHandlerProcessor exceptionHandlerProcessor) {
        this.xmlFilePersistProcessor = xmlFilePersistProcessor;
        this.exceptionHandlerProcessor = exceptionHandlerProcessor;
    }

    @Override
    public void configure() {
        from("file://{{client.input.folder}}/?delete=true")
            .setProperty("originalFileName", simple("${headers.CamelFileName}"))
            .convertBodyTo(byte[].class)
            .setProperty("originalBody", simple("${body}"))
            .doTry()
                .to("xslt:xslt/idoc2order.xsl?output=bytes")
                .process(xmlFilePersistProcessor)
            .doCatch(TransformerException.class)
                .process(exceptionHandlerProcessor)
            .end();

    }
}
