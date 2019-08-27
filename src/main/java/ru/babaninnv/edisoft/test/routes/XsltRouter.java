package ru.babaninnv.edisoft.test.routes;

import org.apache.camel.builder.RouteBuilder;
import org.springframework.stereotype.Component;

/**
 * Роутер для обработки файлов расположенных в директории {@code client.input.folder}
 *
 * @author Nikita Babanin
 * @version 1.0
 */
@Component
public class XsltRouter extends RouteBuilder {

    @Override
    public void configure() {
        from("file://{{client.input.folder}}/?delete=true")
                .setProperty("originalFileName", simple("${headers.CamelFileName}"))
                .convertBodyTo(byte[].class)
                .setProperty("originalBody", simple("${body}"))
                .to("xslt:xslt/idoc2order.xsl?output=bytes")
                .bean("xmlFileService", "create(${exchangeProperty.originalFileName}, ${exchangeProperty.originalBody}, ${body})")
                .to("jpa:ru.babaninnv.edisoft.test.domain.XmlFile")
                .log("Новый файл создан");
    }
}
