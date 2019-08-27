
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:date="http://exslt.org/dates-and-times" xmlns:exsl="http://exslt.org/common"
	xmlns:ns0="urn:lenta.com:EDISOFT:EDIPartin" extension-element-prefixes="exsl date ns0">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="insdes_lines">
		<Lines>
			<xsl:for-each select="//E1EDP01[normalize-space(UEPOS)]">
				<Line>
					<LineNumber>
						<xsl:value-of select="POSEX"/>
					</LineNumber>
					<EAN>
						<xsl:value-of select="E1EDP19[QUALF='003']/IDTNR"/>
					</EAN>
					<ItemDescription>
						<xsl:value-of select="E1EDP19[QUALF='001']/KTEXT"/>
					</ItemDescription>
				</Line>
			</xsl:for-each>
		</Lines>
	</xsl:variable>
	<xsl:variable name="ord_lines">
		<Lines>
			<xsl:for-each select="//E1EDP01[not(contains(E1ADDI1/ADDIFM_TXT,'SLS'))]">
				<Line>
					<LineNumber>
						<xsl:value-of select="POSEX"/>
					</LineNumber>

					<EAN>
						<xsl:value-of select="E1EDP19[QUALF='003']/IDTNR"/>
					</EAN>

					<BuyerItemCode>
						<xsl:value-of select="normalize-space(E1EDP19[QUALF='001']/IDTNR)"/>
					</BuyerItemCode>
				</Line>
			</xsl:for-each>
		</Lines>
	</xsl:variable>
	<xsl:template match="/">
		<Interchange>
			<Group>
				<xsl:apply-templates/>
			</Group>
		</Interchange>
	</xsl:template>


	<!-- ================================================================== -->
	<!-- ORDERS (IDOC - RYADI)  Ivan Bakhmat                                -->
	<!-- ================================================================== -->
	<xsl:template match="/ORDERS05/IDOC[ (contains(E1EDK01/BSART,'ZRZ')) or (contains(E1EDK01/BSART,'ZP')) or (contains(E1EDK01/BSART,'ZNB')) or (contains(E1EDK01/BSART,'Z4')) or (contains(E1EDK01/BSART,'ZNS'))or (contains(E1EDK01/BSART,'NB')) ]">
		<xsl:variable name="lines" select="E1EDP01[not(contains(E1ADDI1/ADDIFM_TXT,'SLS'))]"/>
		<xsl:variable name="lines_1" select="E1EDP01[not(contains(E1ADDI1/ADDIFM_TXT,'SLS')) and (POSEX mod 10 = 0)]"/>
		<xsl:variable name="lines_sls" select="E1EDP01[normalize-space(UEPOS)][normalize-space(E1EDPA1[PARVW='SLS'])]"/>
     	<xsl:variable name="sls">
			<numbers>
				<xsl:for-each select="//E1EDP01[normalize-space(UEPOS)][normalize-space(E1EDPA1[PARVW='SLS'])]">
					<number>
						<xsl:value-of select="UEPOS"/>
					</number>
				</xsl:for-each>
			</numbers>
		</xsl:variable>
		
		<Message>
			<Document-Order>
				<Document-Header>
					<SenderMessageID>
						<xsl:value-of select="format-number(EDI_DC40/DOCNUM,'0000000000000')"/>
					</SenderMessageID>
				</Document-Header>
				<Order-Header>
					<OrderNumber>
						<xsl:value-of select="E1EDK01/BELNR"/>
					</OrderNumber>
					<OrderDate>
						<xsl:call-template name="format-date">
							<xsl:with-param name="date" select="E1EDK03[IDDAT='012']/DATUM"/>
						</xsl:call-template>
					</OrderDate>
					<OrderCurrency>
						<xsl:value-of select="E1EDK01/CURCY"/>
					</OrderCurrency>
					<ExpectedDeliveryDate>
						<xsl:call-template name="format-date">
							<xsl:with-param name="date" select="E1EDP01/E1EDP20/EDATU"/>
						</xsl:call-template>
					</ExpectedDeliveryDate>
					<xsl:if test="string(E1EDK03[IDDAT='001']/UZEIT)">
						<ExpectedDeliveryTime>
							<xsl:call-template name="format-time">
								<xsl:with-param name="time" select="E1EDK03[IDDAT='001']/UZEIT"/>
							</xsl:call-template>
						</ExpectedDeliveryTime>
					</xsl:if>
					<DocumentFunctionCode>9</DocumentFunctionCode>
					<DocumentNameCode>220</DocumentNameCode>
					<Remarks>
						
						<xsl:choose>
							<!--Номер Эдисофта в системе SAP у Рядов: 1000000034-->
							<xsl:when test="E1EDKA1[PARVW='BA']/PARTN = '1000000034'">
								<xsl:value-of select="'2IJ'"/>
							</xsl:when>
							<!--Реальный Контур-->
							<xsl:when test="E1EDKA1[PARVW='BA']/PARTN = '1000000825'">
								<xsl:value-of select="'2BM'"/>
							</xsl:when>
							<!--Реальный Корус-->
							<xsl:when test="E1EDKA1[PARVW='BA']/PARTN = '1000000835'">
								<xsl:value-of select="'2BK'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'2IJ'"/>
							</xsl:otherwise>
						</xsl:choose>
					</Remarks>
					<xsl:if test="normalize-space(E1EDK02[QUALF='006']/BELNR)">
						<Reference>
							<ContractNumber>
								<xsl:value-of select="E1EDK02[QUALF='006']/BELNR"/>
							</ContractNumber>

							<xsl:if test="E1EDK02[QUALF='006']/DATUM">
								<ContractDate>
									<xsl:call-template name="format-date">
										<xsl:with-param name="date"
											select="E1EDK02[QUALF='006']/DATUM"/>
									</xsl:call-template>
								</ContractDate>
							</xsl:if>
						</Reference>
					</xsl:if>
				</Order-Header>
				<Document-Parties>
					<Sender>
						<ILN>
							<xsl:value-of select="E1EDKA1[PARVW='AG']/ILNNR"/>
						</ILN>
					</Sender>

					<Receiver>
						<ILN>
							<xsl:value-of select="E1EDKA1[PARVW='LF']/ILNNR"/>
						</ILN>
					</Receiver>
				</Document-Parties>
				<Order-Parties>
					<Buyer>
						<ILN>
							<xsl:value-of select="E1EDKA1[PARVW='AG']/ILNNR"/>
						</ILN>
						<xsl:if test="E1EDKA1[PARVW='AG']/NAME1">
							<Name>
								<xsl:value-of select="E1EDKA1[PARVW='AG']/NAME1"/>
							</Name>
						</xsl:if>
					</Buyer>
					<Seller>
						<ILN>
							<xsl:value-of select="E1EDKA1[PARVW='LF']/ILNNR"/>
						</ILN>
						<xsl:if test="E1EDKA1[PARVW='LF']/NAME1">
							<Name>
								<xsl:value-of select="E1EDKA1[PARVW='BA']/NAME1"/>
							</Name>
						</xsl:if>
<!--						<CodeByBuyer>
							<xsl:value-of select="number(E1EDKA1[PARVW='BA']/PARTN)"/>
						</CodeByBuyer>-->
					</Seller>
					<DeliveryPoint>
						<ILN>
							<xsl:value-of select="E1EDKA1[PARVW='WE']/ILNNR"/>
						</ILN>

						<xsl:if test="E1EDKA1[PARVW='WE']/NAME1">
							<Name>
								<xsl:value-of select="E1EDKA1[PARVW='WE']/NAME1"/>
							</Name>
						</xsl:if>

						<CodeByBuyer>
							<xsl:value-of select="E1EDKA1[PARVW='WE']/LIFNR"/>
						</CodeByBuyer>

						<xsl:if test="normalize-space( E1EDKA1[PARVW='WE']/STRAS )">
							<StreetAndNumber>
								<xsl:value-of select="E1EDKA1[PARVW='WE']/STRAS"/>
							</StreetAndNumber>
						</xsl:if>

						<xsl:if test="normalize-space( E1EDKA1[PARVW='WE']/ORT01 )">
							<CityName>
								<xsl:value-of select="E1EDKA1[PARVW='WE']/ORT01"/>
							</CityName>
						</xsl:if>

						<xsl:if test="normalize-space( E1EDKA1[PARVW='WE']/PSTLZ )">
							<PostalCode>
								<xsl:value-of select="E1EDKA1[PARVW='WE']/PSTLZ"/>
							</PostalCode>
						</xsl:if>

						<xsl:if test="normalize-space( E1EDKA1[PARVW='WE']/LAND1 )">
							<Country>
								<xsl:value-of select="E1EDKA1[PARVW='WE']/LAND1"/>
							</Country>
						</xsl:if>

						<xsl:if test="normalize-space( E1EDKA1[PARVW='WE']/TELF1 )">
							<PhoneNumber>
								<xsl:value-of select="E1EDKA1[PARVW='WE']/TELF1"/>
							</PhoneNumber>
						</xsl:if>
					</DeliveryPoint>

					<!-- START: Добавил Николай Лямин, клиенты просят адрес конечного получателя в заказе -->

					<xsl:if test="E1EDP01/E1EDPA1[PARVW='SLS']/PARTN">
						<UltimateCustomer>
							<ILN>
								<xsl:value-of select="E1EDP01/E1EDPA1[PARVW='SLS']/PARTN"/>
							</ILN>
							<!--<Name>
								<xsl:value-of select=" substring( concat( E1EDP01/E1EDPA1[PARVW='SLS']/NAME1, ', ',E1EDP01/E1EDPA1[PARVW='SLS']/NAME2, ' (', E1EDP01/E1EDPA1[PARVW='SLS']/STRAS, ')' ), 1,175)"/>
							</Name>-->
							<CodeByBuyer>
								<xsl:value-of select="number(E1EDP01/E1EDPA1[PARVW='SLS']/NAME4)"/>
							</CodeByBuyer>
						</UltimateCustomer>
					</xsl:if>

					<!-- END: Добавил Николай Лямин, клиенты просят адрес конечного получателя в заказе -->
				</Order-Parties>

				<Order-Lines>
					<xsl:apply-templates select="$lines" mode="Order"/>
				</Order-Lines>

				<Order-Summary>
					<!--КК 23.07.2013
	       исправление по запросу клиента - если по заказу есть InsDes, то задваивается общее количество строк в заказе на платформе-->
					<TotalLines>
						<xsl:choose>
							<xsl:when test="count(exsl:node-set($sls)/numbers/number) &gt; 0">
								<xsl:value-of select="(count($lines)div 2)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="count($lines)"/>
							</xsl:otherwise>
						</xsl:choose>
					</TotalLines>

					<TotalOrderedAmount>
						<xsl:value-of select="format-number(sum($lines_1/BMNG2), '#0.000')"/>
					</TotalOrderedAmount>

					<xsl:if test="number(E1EDS01[SUMID='002']/SUMME)">
						<TotalNetAmount>
							<xsl:value-of
								select="format-number(E1EDS01[SUMID='002']/SUMME, '#0.0000')"/>
						</TotalNetAmount>
					</xsl:if>

					<TotalGrossAmount>
						<xsl:value-of
							select="format-number(sum($lines/E1EDP04[MWSKZ='VAT']/KTEXT), '#0.000')"
						/>
					</TotalGrossAmount>

					<TotalTaxAmount>
						<xsl:value-of
							select="format-number(sum($lines/E1EDP04[MWSKZ='VAT']/MWSBT), '#0.000')"
						/>
					</TotalTaxAmount>
				</Order-Summary>
			</Document-Order>
		</Message>


		<xsl:if test="count(exsl:node-set($sls)/numbers/number) &gt; 0">
			<Message>
				<Document-InstructionToDespatch>
					<InstructionToDespatch-Header>
						<InstructionToDespatchNumber>
							<xsl:value-of select="E1EDK01/BELNR"/>
						</InstructionToDespatchNumber>

						<InstructionToDespatchDate>
							<xsl:call-template name="format-date">
								<xsl:with-param name="date" select="E1EDK03[IDDAT='012']/DATUM"/>
							</xsl:call-template>
						</InstructionToDespatchDate>

						<ExpectedDeliveryDate>
							<xsl:call-template name="format-date">
								<xsl:with-param name="date" select="E1EDP01/E1EDP20/EDATU"/>
							</xsl:call-template>
						</ExpectedDeliveryDate>

						<xsl:if test="string(E1EDK03[IDDAT='001']/UZEIT)">
							<ExpectedDeliveryTime>
								<xsl:call-template name="format-time">
									<xsl:with-param name="time" select="E1EDK03[IDDAT='001']/UZEIT"
									/>
								</xsl:call-template>
							</ExpectedDeliveryTime>
						</xsl:if>

						<DocumentFunctionCode>
							<xsl:value-of select="'9'"/>
						</DocumentFunctionCode>

						<DocumentNameCode>
							<xsl:value-of select="'297'"/>
							<!-- Instruction to collect -->
						</DocumentNameCode>

						<xsl:if test="E1EDKT1[TDID='F01']/E1EDKT2/TDLINE">
							<Remarks>
								<xsl:value-of select="E1EDKT1[TDID='F01']/E1EDKT2/TDLINE"/>
							</Remarks>
						</xsl:if>


						<xsl:if test="normalize-space(E1EDK02[QUALF='006']/BELNR)">
							<Reference>
								<OrderReferenceNumber>1</OrderReferenceNumber>
								<Reference-Elements>
									<Reference-Element>
										<Reference-Type>CT</Reference-Type>
										<Reference-Id>
											<xsl:value-of select="E1EDK02[QUALF='006']/BELNR"/>
										</Reference-Id>
										<xsl:if test="E1EDK02[QUALF='006']/DATUM">
											<Reference-Date>
												<xsl:call-template name="format-date">
												<xsl:with-param name="date"
												select="E1EDK02[QUALF='006']/DATUM"/>
												</xsl:call-template>
											</Reference-Date>
										</xsl:if>
									</Reference-Element>
								</Reference-Elements>
							</Reference>
						</xsl:if>
					</InstructionToDespatch-Header>


					<Document-Parties>
						<Sender>
							<ILN>
								<xsl:value-of select="E1EDKA1[PARVW='AG']/ILNNR"/>
							</ILN>
						</Sender>

						<Receiver>
							<ILN>
								<xsl:value-of select="E1EDKA1[PARVW='LF']/ILNNR"/>
							</ILN>
						</Receiver>
					</Document-Parties>

					<InstructionToDespatch-Parties>

						<Buyer>
							<ILN>
								<xsl:value-of select="E1EDKA1[PARVW='AG']/ILNNR"/>
							</ILN>
							<xsl:if test="E1EDKA1[PARVW='AG']/NAME1">
								<Name>
									<xsl:value-of select="E1EDKA1[PARVW='AG']/NAME1"/>
								</Name>
							</xsl:if>
						</Buyer>


						<Seller>
							<ILN>
								<xsl:value-of select="E1EDKA1[PARVW='LF']/ILNNR"/>
							</ILN>
							<CodeByBuyer>
								<xsl:value-of select="number(E1EDKA1[PARVW='LF']/PARTN)"/>
							</CodeByBuyer>
							<xsl:if test="E1EDKA1[PARVW='LF']/NAME1">
								<Name>
									<xsl:value-of select="E1EDKA1[PARVW='LF']/NAME1"/>
								</Name>
							</xsl:if>
						</Seller>


						<DeliveryPoint>
							<ILN>
								<xsl:value-of select="E1EDKA1[PARVW='WE']/ILNNR"/>
							</ILN>

							<CodeByBuyer>
								<xsl:value-of select="E1EDKA1[PARVW='WE']/LIFNR"/>
							</CodeByBuyer>


							<xsl:if test="E1EDKA1[PARVW='WE']/NAME1">
								<Name>
									<xsl:value-of select="E1EDKA1[PARVW='WE']/NAME1"/>
								</Name>
							</xsl:if>

							<xsl:if test="normalize-space( E1EDKA1[PARVW='WE']/STRAS )">
								<StreetAndNumber>
									<xsl:value-of select="E1EDKA1[PARVW='WE']/STRAS"/>
								</StreetAndNumber>
							</xsl:if>

							<xsl:if test="normalize-space( E1EDKA1[PARVW='WE']/ORT01 )">
								<CityName>
									<xsl:value-of select="E1EDKA1[PARVW='WE']/ORT01"/>
								</CityName>
							</xsl:if>

							<xsl:if test="normalize-space( E1EDKA1[PARVW='WE']/PSTLZ )">
								<PostalCode>
									<xsl:value-of select="E1EDKA1[PARVW='WE']/PSTLZ"/>
								</PostalCode>
							</xsl:if>

							<xsl:if test="normalize-space( E1EDKA1[PARVW='WE']/LAND1 )">
								<Country>
									<xsl:value-of select="E1EDKA1[PARVW='WE']/LAND1"/>
								</Country>
							</xsl:if>
						</DeliveryPoint>
					</InstructionToDespatch-Parties>

					<xsl:variable name="processed_lines">
						<xsl:apply-templates mode="INSDES" select="$lines_sls"/>
					</xsl:variable>


					<InstructionToDespatch-Lines>
						<xsl:apply-templates select="$lines_sls" mode="INSDES"/>
					</InstructionToDespatch-Lines>

					<InstructionToDespatch-Summary>
						<TotalLines>
							<xsl:value-of select="count($lines_sls)"/>
						</TotalLines>

						<TotalOrderedAmount>
							<xsl:value-of
								select=" format-number( sum( exsl:node-set($processed_lines)/Line/Line-Item/QuantityToBeDelivered), '0.00' )"
							/>
						</TotalOrderedAmount>
					</InstructionToDespatch-Summary>
				</Document-InstructionToDespatch>
			</Message>
		</xsl:if>


		<!-- SystemMessage for ORDERS -->
<!--		<Message>
			<Document-SystemMessage>
				<SystemMessage-Header>
					<SysыtemMessageNumber>
						<xsl:value-of select="EDI_DC40/DOCNUM"/>
					</SystemMessageNumber>
					<SystemMessageDate>
						<xsl:call-template name="format-date">
							<xsl:with-param name="date" select="E1EDK03[IDDAT='012']/DATUM"/>
						</xsl:call-template>
					</SystemMessageDate>
					<SystemMessageReference>
						<DocumentType>ORDER</DocumentType>
						<DocumentNumber>
							<xsl:value-of select="EDI_DC40/DOCNUM"/>
						</DocumentNumber>
						<DocumentDate>
							<xsl:call-template name="format-date">
								<xsl:with-param name="date" select="E1EDK03[IDDAT='012']/DATUM"/>
							</xsl:call-template>
						</DocumentDate>
					</SystemMessageReference>
				</SystemMessage-Header>
				<Document-Parties>
					<Sender>
						<ILN>
							<xsl:value-of select="E1EDKA1[PARVW='AG']/ILNNR"/>
						</ILN>
					</Sender>
					<Receiver>
						<ILN>
							<xsl:value-of select="E1EDKA1[PARVW='AG']/ILNNR"/>
						</ILN>
					</Receiver>
				</Document-Parties>
				<SystemMessage-Lines/>
				<SystemMessage-Summary>
					<TotalLines>1</TotalLines>
				</SystemMessage-Summary>
			</Document-SystemMessage>
		</Message>-->
	</xsl:template>

	<!-- ORDER lines -->
	<xsl:template match="E1EDP01[not(contains(E1ADDI1/ADDIFM_TXT,'SLS'))]" mode="Order">

		<xsl:variable name="pos" select="UEPOS"/>
		<xsl:variable name="buyer_code" select="normalize-space(E1EDP19[QUALF='001']/IDTNR)"/>
		<xsl:if test="normalize-space(exsl:node-set($ord_lines)/Lines/Line[LineNumber=$pos]/BuyerItemCode) != $buyer_code ">
			<Line>
				<Line-Item>
					<LineNumber>
						<xsl:value-of select="number(POSEX)"/>
					</LineNumber>
					<EAN>
						<xsl:value-of select="E1EDP19[QUALF='003']/IDTNR"/>
					</EAN>
					<BuyerItemCode>
						<xsl:value-of select="number(E1EDP19[QUALF='001']/IDTNR)"/>
					</BuyerItemCode>
					<xsl:if test="E1EDP19[QUALF='002']/IDTNR">
						<SupplierItemCode>
							<xsl:value-of select="E1EDP19[QUALF='002']/IDTNR"/>
						</SupplierItemCode>
					</xsl:if>
					<ItemDescription>
						<xsl:value-of select="E1EDP19[QUALF='001']/KTEXT"/>
					</ItemDescription>
					<OrderedQuantity>
						<xsl:value-of select="format-number(MENGE, '#0.000')"/>
					</OrderedQuantity>
					<OrderedUnitPacksize>1.00</OrderedUnitPacksize>

					<!-- Изменил рассчет поля BuyerUnitPacksize 20.02.2015 Амплеев А.В. -->
					<xsl:if test="normalize-space(BPUMZ)">
						<BuyerUnitPacksize>
							<xsl:choose>
								<xsl:when test="PMENE='GRM'">
									<xsl:value-of select="format-number((number(BPUMZ div BPUMN) div 1000),'0.000')"/>
								</xsl:when>
								<xsl:when test="PMENE='KGM'">
									<xsl:value-of select="format-number(number(BPUMZ div BPUMN),'0.000')"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="format-number(number(BPUMZ div BPUMN),'0.0')"/>
								</xsl:otherwise>
							</xsl:choose>
						</BuyerUnitPacksize>
					</xsl:if>

					<!--
				<xsl:if test="number(ZE1EDP4/UMREZ)">
					<OrderedUnitPacksize>
						<xsl:call-template name="divide">
							<xsl:with-param name="numerator" select="ZE1EDP4/UMREZ"/>
							<xsl:with-param name="denominator" select="ZE1EDP4/UMREN"/>
							<xsl:with-param name="format" select="'#0.000'"/>
						</xsl:call-template>
					</OrderedUnitPacksize>
				</xsl:if>
				-->
					<!-- Изменил формат вывода поля ItemNumerator 20.02.2015 Амплеев А.В.-->
					<xsl:if test="normalize-space(BPUMZ)">
						<ItemNumerator>
							<xsl:value-of select="BPUMZ"/>
						</ItemNumerator>
					</xsl:if>

					<xsl:if test="normalize-space(BPUMN)">
						<ItemDenumerator>
							<xsl:value-of select="BPUMN"/>
						</ItemDenumerator>
					</xsl:if>
					<xsl:if test="number(MENGE)">
						<OrderedBoxes>
							<xsl:value-of select="MENGE"/>
						</OrderedBoxes>
					</xsl:if>

					<UnitOfMeasure>
						<xsl:choose>
							<xsl:when test="MENEE!=PMENE">
								<xsl:value-of select="MENEE"/>
							</xsl:when>
							<xsl:when test="MENEE=PMENE">
								<xsl:value-of select="PMENE"/>
							</xsl:when>
						</xsl:choose>
						<!--<xsl:value-of select="PMENE"/>-->
					</UnitOfMeasure>

					<OrderedUnitNetPrice>
						<xsl:choose>
							<!-- Калганова Мария + Наталия Т. добавили условия, чтобы цена расчитывалась с учётом ед.из. цены (PMENE)-->
							<!-- 31.03.15 TLW-793-30555 -->
							<xsl:when
								test="number(VPREI) and number(PEINH) and number(../E1EDKA1[PARVW='LF']/ILNNR) = '4606405999992'">
								<xsl:choose>
									<xsl:when test="MENEE=PMENE">
										<xsl:call-template name="divide">
											<xsl:with-param name="numerator" select="VPREI"/>
											<xsl:with-param name="denominator" select="PEINH"/>
											<xsl:with-param name="format" select="'#0.0000'"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="MENEE!=PMENE">
										<xsl:choose>
											<xsl:when test="PMENE='KGM' and GEWEI='GRM'">
												<xsl:call-template name="divide">
												<xsl:with-param name="numerator"
												select="VPREI * number(BPUMZ div BPUMN)"/>
												<xsl:with-param name="denominator" select="PEINH"/>
												<xsl:with-param name="format" select="'#0.0000'"/>
												</xsl:call-template>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="divide">
												<xsl:with-param name="numerator"
												select="VPREI * BPUMZ"/>
												<xsl:with-param name="denominator" select="PEINH"/>
												<xsl:with-param name="format" select="'#0.0000'"/>
												</xsl:call-template>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>0.00</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="number(VPREI) and number(PEINH)">
								<xsl:call-template name="divide">
									<xsl:with-param name="numerator" select="VPREI"/>
									<xsl:with-param name="denominator" select="PEINH"/>
									<xsl:with-param name="format" select="'#0.0000'"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>0.00</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</OrderedUnitNetPrice>

					<xsl:choose>
						<xsl:when test="number(NETWR)">
							<OrderedNetAmount>
								<xsl:value-of select="format-number(NETWR, '#0.0000')"/>
							</OrderedNetAmount>
						</xsl:when>
						<xsl:otherwise>
							<OrderedNetAmount>
								<xsl:value-of select="'0.00'"/>
							</OrderedNetAmount>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:choose>
						<xsl:when test="normalize-space(E1EDP04[MWSKZ='VAT']/MWSBT)">
							<OrderedTaxAmount>
								<xsl:value-of
									select="format-number(E1EDP04[MWSKZ='VAT']/MWSBT, '#0.0000')"/>
							</OrderedTaxAmount>
						</xsl:when>
						<xsl:otherwise>
							<OrderedTaxAmount>
								<xsl:value-of select="'0.00'"/>
							</OrderedTaxAmount>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:choose>
						<xsl:when test="normalize-space(E1EDP04[MWSKZ='VAT']/KTEXT)">
							<OrderedGrossAmount>
								<xsl:value-of
									select="format-number(E1EDP04[MWSKZ='VAT']/KTEXT, '#0.0000')"/>
							</OrderedGrossAmount>
						</xsl:when>
						<xsl:otherwise>
							<OrderedGrossAmount>
								<xsl:value-of select="'0.00'"/>
							</OrderedGrossAmount>
						</xsl:otherwise>
					</xsl:choose>


					<xsl:if test="normalize-space(E1EDP04[MWSKZ='VAT']/MSATZ)">
						<TaxRate>
							<xsl:value-of select="normalize-space(E1EDP04[MWSKZ='VAT']/MSATZ)"/>
						</TaxRate>
					</xsl:if>


					<!--					<xsl:if test="normalize-space(UEPOS)">
						<Remarks>
							<xsl:text>Компонента набора</xsl:text>
						</Remarks>
					</xsl:if>-->
					<xsl:if test="MENEE!=PMENE">
						<Remarks>
							<xsl:text>NB! Позиция заказана в коробах!</xsl:text>
						</Remarks>
					</xsl:if>
				</Line-Item>
			</Line>
		</xsl:if>
	</xsl:template>

	

	<!-- ================================================================== -->
	<!-- RECADV (IDOC - RYADI)                                        		-->
	<!-- ================================================================== -->
	<xsl:template match="/DELVRY03/IDOC">
		<xsl:variable name="recadv_net_amount">
			<xsl:for-each select="E1EDL20/E1EDL24">
				<number>
					<xsl:value-of select="number(LFIMG) * number(USR01)"/>
				</number>
			</xsl:for-each>
		</xsl:variable>
		<Message>
			<Document-ReceivingAdvice>
				<Document-Header>
					<SenderMessageID>
						<xsl:value-of select="format-number(EDI_DC40/DOCNUM,'0000000000000')"/>
					</SenderMessageID>
				</Document-Header>
				<ReceivingAdvice-Header>
					<ReceivingAdviceNumber>
						<xsl:value-of select="format-number(EDI_DC40/DOCNUM,'#')"/>
					</ReceivingAdviceNumber>
					<ReceivingAdviceDate>
						<xsl:call-template name="format-date">
							<xsl:with-param name="date" select="EDI_DC40/CREDAT"/>
						</xsl:call-template>
					</ReceivingAdviceDate>
					<GoodsReceiptDate>
						<xsl:call-template name="format-date">
							<xsl:with-param name="date" select="E1EDL20/PODAT"/>
						</xsl:call-template>
					</GoodsReceiptDate>
					<BuyerOrderNumber>
						<xsl:value-of select="E1EDL20/E1EDL24/E1EDL43[QUALF='V']/BELNR"/>
					</BuyerOrderNumber>
					<BuyerOrderDate>
						<xsl:call-template name="format-date">
							<xsl:with-param name="date"
								select="E1EDL20/E1EDL24/E1EDL43[QUALF='V']/DATUM"/>
						</xsl:call-template>
					</BuyerOrderDate>
					<DespatchNumber>
						<xsl:value-of select="E1EDL20/LIFEX"/>
					</DespatchNumber>
					<DocumentFunctionCode>9</DocumentFunctionCode>
					<DocumentNameCode>
						<xsl:value-of select="'632'"/>
					</DocumentNameCode>
					<Remarks>
						<!--Номер Эдисофта в системе SAP у Рядов по РЕКАДВАМ: 1000000034-->
						<xsl:choose>
							<xsl:when test="E1EDL20/E1ADRM1[PARTNER_Q = 'BA']/PARTNER_ID = '1000000034'">
								<xsl:value-of select="'2IJ'"/>
							</xsl:when>
							<!--Номер Контура-->
							<xsl:when test="E1EDL20/E1ADRM1[PARTNER_Q = 'BA']/PARTNER_ID = '1000000825'">
								<xsl:value-of select="'2BM'"/>
							</xsl:when>		
						    <!--Номер Коруса-->
							<xsl:when test="E1EDL20/E1ADRM1[PARTNER_Q = 'BA']/PARTNER_ID = '1000000835'">
								<xsl:value-of select="'2BK'"/>
							</xsl:when>	
							<xsl:otherwise>
								<xsl:value-of select="'2IJ'"/>
							</xsl:otherwise>
						</xsl:choose>
					</Remarks>
				</ReceivingAdvice-Header>
				<Document-Parties>
					<Sender>
						<ILN>
							<xsl:value-of select="'4607974599996'"/>
						</ILN>
					</Sender>
					<Receiver>
						<ILN>
							<!--<!-\-  GLN matching -\->-->
							<xsl:value-of select="E1EDL20/E1ADRM1[PARTNER_Q='LF']/E1ADRE1/EXTEND_D"/>
						</ILN>
					</Receiver>
				</Document-Parties>

				<ReceivingAdvice-Parties>
					<Buyer>
						<ILN>
							<xsl:value-of select="'4607974599996'"/>
						</ILN>
					</Buyer>
					<Seller>
						<ILN>
							<xsl:value-of select="E1EDL20/E1ADRM1[PARTNER_Q='LF']/E1ADRE1/EXTEND_D"/>
						</ILN>
						<Name>
							<xsl:value-of select="E1EDL20/E1ADRM1[PARTNER_Q='LF']/NAME1"/>
						</Name>
					</Seller>

					<DeliveryPoint>
						<ILN>
							<xsl:value-of select="E1EDL20/E1ADRM1[PARTNER_Q='OSP']/E1ADRE1/EXTEND_D"/>
						</ILN>
					</DeliveryPoint>
				</ReceivingAdvice-Parties>

				<xsl:variable name="lines" select="E1EDL20/E1EDL24"/>

				<xsl:variable name="processed_lines">
					<xsl:apply-templates mode="RECADV" select="$lines"/>
				</xsl:variable>
				<ReceivingAdvice-Lines>
					<xsl:copy-of select="$processed_lines"/>
				</ReceivingAdvice-Lines>
				<ReceivingAdvice-Summary>
					<TotalLines>
						<xsl:value-of select="count($lines)"/>
					</TotalLines>
					<TotalGoodsReceiptAmount>
						<xsl:value-of select="format-number(sum(exsl:node-set($processed_lines)/Line/Line-Item/QuantityReceived),'0.00')"/>
					</TotalGoodsReceiptAmount>

					<TotalNetAmount>
						<xsl:value-of select="format-number( sum( exsl:node-set($recadv_net_amount)/number),'0.00')"/>
					</TotalNetAmount>
				</ReceivingAdvice-Summary>
			</Document-ReceivingAdvice>
		</Message>
	</xsl:template>

	<!-- RECADV lines -->
	<xsl:template mode="RECADV" match="E1EDL20/E1EDL24">
		<Line>
			<Line-Item>
				<LineNumber>
					<xsl:value-of select="position()"/>
				</LineNumber>
				<xsl:if test="string( EAN11 )">
					<EAN>
						<xsl:value-of select="normalize-space(EAN11)"/>
					</EAN>
				</xsl:if>
				<xsl:if test="string( MATNR )">
					<BuyerItemCode>
						<xsl:value-of select="normalize-space(MATNR)"/>
					</BuyerItemCode>
				</xsl:if>
				<xsl:if test="string( ARKTX )">
					<ItemDescription>
						<xsl:value-of select="normalize-space( ARKTX )"/>
					</ItemDescription>
				</xsl:if>
				<QuantityOrdered>
					<xsl:value-of select="normalize-space(ORMNG)"/>
				</QuantityOrdered>
				<QuantityReceived>
					<xsl:value-of select="normalize-space(LFIMG)"/>
				</QuantityReceived>
				<UnitPacksize>
					<xsl:value-of select="normalize-space(E1EDL26/UMVKZ)"/>
				</UnitPacksize>
				<UnitNetPrice>
					<xsl:value-of select="format-number(USR01,'0.00')"/>
				</UnitNetPrice>
				<UnitOfMeasure>
					<xsl:value-of select="normalize-space(VRKME)"/>
				</UnitOfMeasure>
			</Line-Item>
		</Line>
	</xsl:template>

	<!-- ================================================================== -->
	<!-- PARTIN (IDOC - LENTA)                                        		-->
	<!-- ================================================================== -->
	<xsl:template match="ns0:MT_PARTIN">
		<Message>
			<Document-DeliveryLocalizationsCatalog>
				<LocalizationsCatalog-Header>
					<LocalizationsCatalogNumber>
						<xsl:value-of select="substring-before(date:date-time(),'T')"/>
					</LocalizationsCatalogNumber>
					<LocalizationsCatalogDate>
						<xsl:value-of select="substring-before(date:date-time(),'T')"/>
					</LocalizationsCatalogDate>
					<DocumentFunctionCode>9</DocumentFunctionCode>
				</LocalizationsCatalog-Header>
				<Document-Parties>
					<Sender>
						<ILN>4606068999995</ILN>
						<Name>Лента, ООО</Name>
					</Sender>
					<Receiver>
						<ILN>4606068999995</ILN>
					</Receiver>
				</Document-Parties>
				<LocalizationsCatalog-Localizations>
					<xsl:for-each select="ZPARTIN/IDOC/E1EDPP1">
						<Localization>
							<ILN>
								<xsl:value-of select="E1ADRM0/E1ADRE0[EXTEND_Q='GLN']/EXTEND_D"/>
							</ILN>
							<TaxID>
								<xsl:value-of select="E1ADRM0/E1ADRE0[EXTEND_Q='INN']/EXTEND_D"/>
							</TaxID>
							<TaxRegistrationReasonCode>
								<xsl:value-of select="E1ADRM0/E1ADRE0[EXTEND_Q='KPP']/EXTEND_D"/>
							</TaxRegistrationReasonCode>
							<UtilizationRegisterNumber>
								<xsl:value-of select="E1ADRM0/E1ADRE0[EXTEND_Q='KPP']/EXTEND_D"/>
							</UtilizationRegisterNumber>
							<Name>
								<xsl:value-of select="E1ADRM0/NAME1"/>
							</Name>
							<StreetAndNumber>
								<xsl:value-of
									select="concat(E1ADRM0/STREET1,' ',E1ADRM0/HOUSE_RANG)"/>
							</StreetAndNumber>
							<CityName>
								<xsl:value-of select="E1ADRM0/CITY1"/>
							</CityName>
							<PostalCode>
								<xsl:value-of select="E1ADRM0/POSTL_COD1"/>
							</PostalCode>
							<Country>RU</Country>
							<Headquarters>
								<ILN>4606068999995</ILN>
								<TaxID>7814148471</TaxID>
								<UtilizationRegisterNumber>1037832048605</UtilizationRegisterNumber>
								<Name>Лента, ООО</Name>
							</Headquarters>
						</Localization>
					</xsl:for-each>
				</LocalizationsCatalog-Localizations>
				<LocalizationsCatalog-Summary>
					<TotalLines>
						<xsl:value-of select="count(ns0:MT_PARTIN/ZPARTIN/IDOC/E1EDPP1)"/>
					</TotalLines>
				</LocalizationsCatalog-Summary>
			</Document-DeliveryLocalizationsCatalog>
		</Message>
	</xsl:template>
	<xsl:template name="format-date">
		<xsl:param name="date"/>
		<xsl:variable name="tmp" select="normalize-space($date)"/>
		<xsl:value-of select="concat(substring($tmp, 1, 4), '-', substring($tmp, 5, 2), '-', substring($tmp, 7, 2))"/>
	</xsl:template>
	<xsl:template name="format-time">
		<xsl:param name="time"/>
		<xsl:variable name="tmp" select="normalize-space($time)"/>
		<xsl:value-of select="concat(substring($tmp, 1, 2), ':', substring($tmp, 3, 2))"/>
	</xsl:template>
	<xsl:template name="divide">
		<xsl:param name="numerator"/>
		<xsl:param name="denominator"/>
		<xsl:param name="format" select="'#0.0000'"/>
		<xsl:if test="number($numerator)">
			<xsl:variable name="tmpden">
				<xsl:choose>
					<xsl:when test="number($denominator) and ($denominator != '0')">
						<xsl:value-of select="number($denominator)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>1</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="format-number($numerator div $tmpden, $format)"/>
		</xsl:if>
	</xsl:template>

	<!-- INSDES lines -->
	<xsl:template match="E1EDP01[normalize-space(UEPOS)][normalize-space(E1EDPA1[PARVW='SLS'])]" mode="INSDES">
		<xsl:variable name="pos" select="UEPOS"/>
		<Line>
			<Line-Item>
				
				<LineNumber>
					<xsl:value-of select="position() * 10"/>
				</LineNumber>
				<EAN>
					<xsl:value-of select="exsl:node-set($insdes_lines)/Lines/Line[LineNumber=$pos]/EAN"/>
				</EAN>
				<ItemDescription>
					<xsl:value-of select="substring( exsl:node-set($insdes_lines)/Lines/Line[LineNumber=$pos]/ItemDescription, 1,100)" />
				</ItemDescription>
				<QuantityToBeDelivered>
					<xsl:value-of select="format-number(E1ADDI1/ADDINUMBER, '#0.000')"/>
				</QuantityToBeDelivered>
				<UnitOfMeasure>
					<xsl:value-of select="E1ADDI1/ADDIVKME"/>
				</UnitOfMeasure>
				<Remarks>
					<xsl:value-of select="E1ADDI1/ADDIFM_TXT"/>
				</Remarks>
			</Line-Item>
			<Line-ShipFrom>
				<ILN>
					<xsl:value-of select="E1EDPA1[PARVW='SLS']/PARTN"/>
				</ILN>
				<Name>
					<xsl:value-of select=" substring( concat( E1EDPA1[PARVW='SLS']/NAME1, ', ',E1EDPA1[PARVW='SLS']/NAME2, ' (', E1EDPA1[PARVW='SLS']/STRAS, ')' ), 1,175)" />
				</Name>
			</Line-ShipFrom>
		</Line>
	</xsl:template>
</xsl:stylesheet>
