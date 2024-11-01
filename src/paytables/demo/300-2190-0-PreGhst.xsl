<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:x="anything">
	<xsl:namespace-alias stylesheet-prefix="x" result-prefix="xsl" />
	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	<xsl:include href="../utils.xsl" />

	<xsl:template match="/Paytable">
		<x:stylesheet version="1.0" xmlns:java="http://xml.apache.org/xslt/java" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
			exclude-result-prefixes="java" xmlns:lxslt="http://xml.apache.org/xslt" xmlns:my-ext="ext1" extension-element-prefixes="my-ext">
			<x:import href="HTML-CCFR.xsl" />
			<x:output indent="no" method="xml" omit-xml-declaration="yes" />

			<!-- TEMPLATE Match: -->
			<x:template match="/">
				<x:apply-templates select="*" />
				<x:apply-templates select="/output/root[position()=last()]" mode="last" />
				<br />
			</x:template>

			<!--The component and its script are in the lxslt namespace and define the implementation of the extension. -->
			<lxslt:component prefix="my-ext" functions="formatJson,retrievePrizeTable,getType">
				<lxslt:script lang="javascript">
					<![CDATA[
					var debugFeed = [];
					var debugFlag = false;
					var bonusTotal = 0; 
					// Format instant win JSON results.
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function formatJson(jsonContext, translations, prizeTable, prizeValues, prizeNamesDesc)
					{
						var scenario = getScenario(jsonContext);
						var mainGameData = getGameData(scenario);
						var prizeNames = (prizeNamesDesc.substring(1)).split(',');
						var convertedPrizeValues = (prizeValues.substring(1)).split('|');
						var IWPrizes = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O"];
						var targetPrizes = ["I1","I2","I3","I4","I5","I6","I7","I8","I9","I10","I11","I12"];
						var muliplierPrizes = ["S1","S2","S3","S4","S5","S6","S7","S8","S9","S10","S11"];

						//var formatter = new Intl.NumberFormat('nb-NO', {style: 'currency', currency: 'NOK'});

						// Output winning numbers table.
						var r = [];

 						r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
 						r.push('<tr>');
 						r.push('<td class="tablehead" width="10%">');
 						r.push(getTranslationByName("pick", translations));
 						r.push('</td>');
 						r.push('<td class="tablehead" width="20%">');
 						r.push('</td>');
 						r.push('<td class="tablehead" width="20%">');
 						r.push(getTranslationByName("wins", translations));
 						r.push('</td>');
						r.push('</tr>');

						var bonus1 = 0;
						var bonus2 = 0;
						var letter = "";
					//	var mainCashWin = 0;
 						for(var i = 0; i < mainGameData.length; ++i)
 						{
							letter = mainGameData[i];
 							r.push('<tr>');
							r.push('<td>');
							r.push(i+1);
							r.push('</td>');

 							r.push('<td>');
							if (IWPrizes.indexOf(letter) != -1)
							{
 								r.push(getTranslationByName("instantWin", translations)); // + " " + letter);
							}
							else
							{
								r.push(getTranslationByName(letter, translations));
							}
 							r.push('</td>');
							if (IWPrizes.indexOf(letter) != -1)
							{
								r.push('<td>');
 								r.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, letter)]);
						//		mainCashWin += (getPrizeAsFloat(convertedPrizeValues[getPrizeNameIndex(prizeNames, letter)]));
 								r.push('</td>');
							}
							if (letter == "1") 
							{
								bonus1++;
							}
							if (letter == "2") 
							{
								bonus2++;
							}
 							r.push('</tr>');
 						}

						if ((bonus1 == 3) || (bonus2 == 3))
						{
 							r.push('<tr>');
							if (bonus1 == 3)
							{
								r.push('<td>');
 								r.push(getTranslationByName("bonus1Triggered", translations));
 								r.push('</td>');
							}
							if (bonus2 == 3)
							{
								r.push('<td>');
 								r.push(getTranslationByName("bonus2Triggered", translations));
 								r.push('</td>');
							}
 							r.push('</tr>');
						}
 						r.push('</table>');
						r.push('&nbsp;');

						if (bonus1 == 3)
						{	// "I11,115,57,59:I9,242,68,61:I7,354,67,49:I5,487,63,65:I2,616,61,67"
							var bonus1Data = getBonus1GameData(scenario);

							// Test Run through data to determin which is the final win level
							var playData = [];
							var currentTotal = 0;
							var finalWins = 0;
							for(var i = 0; i < bonus1Data.length; ++i)
							{
								playData = bonus1Data[i].split(",");
								var playTarget = playData[1];
								for(var j = 0; j < playData.length; j++)
								{
									if ((j == 2) || (j == 3))
									{
										currentTotal += + playData[j];
									}
								}
								var playTargetTwenty = playTarget + 20;
								if ((currentTotal >= playTarget) && (currentTotal <= playTargetTwenty))
								{
									finalWins = i;
								}
							}

							// Output outcome numbers table.
 							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							r.push('<tr>');
 							r.push('<td class="tablehead" width="20%">');
 							r.push(getTranslationByName("level", translations));
 							r.push('</td>');
 							r.push('<td class="tablehead" width="15%">');
 							r.push(getTranslationByName("targetPrize", translations));
 							r.push('</td>');
 							r.push('<td class="tablehead" width="10%">');
	 						r.push(getTranslationByName("spiritTarget", translations));
							r.push('</td>');
							r.push('<td class="tablehead" width="10%">');
 							r.push(getTranslationByName("spiritSelection", translations));
							r.push('</td>');
 							r.push('<td class="tablehead" width="10%">');
 							r.push(getTranslationByName("spiritTotal", translations));
 							r.push('</td>');
 							r.push('<td class="tablehead" width="15%">');
 							r.push(getTranslationByName("wins", translations));
 							r.push('</td>');
 							r.push('</tr>');

							playData = [];
							currentTotal = 0;
							var linePrinted = false;
							for(var i = 0; i < bonus1Data.length; ++i)
							{
								playData = bonus1Data[i].split(",");
								linePrinted = false;
								if (playData[2] > 0)
								{
									linePrinted = true;
									var playTarget = playData[1];
									r.push('<tr>');
									r.push('<td>');
									r.push((i+1).toString());
									r.push('</td>');
									for(var j = 0; j < playData.length; j++)
									{
										if (j == 0)
										{
											r.push('<td>' + convertedPrizeValues[getPrizeNameIndex(prizeNames, playData[0])] + '</td>');
										}
										else if (j == 1)
										{
											r.push('<td>' + playData[1] + '</td>');
										}
										else if (j == 3)
										{
											r.push('<td>' + (parseInt(playData[2]) + parseInt(playData[3])).toString() + '</td>')
										}
										
										if (j == 2 || j == 3)
										{
											currentTotal += parseInt(playData[j]);
										}
									}
								}
								if(linePrinted == true)
								{
									r.push('<td>');
									r.push(currentTotal);
									r.push('</td>');
									if (i == finalWins)
									{
										r.push('<td>');
										r.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, playData[0])]);
										r.push('</td>');
									}
 									r.push('</tr>');
								}
							}
							r.push('</table>');
							r.push('&nbsp;');
						}

						if (bonus2 == 3)
						{	// "S6,M,M,S8,S11,S2,M,S1,M,S8,X"
							var bonus2Data = getBonus2GameData(scenario);
							var multiplier = 1;
							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							r.push('<tr>');
 							r.push('<td class="tablehead" width="10%">');
 							r.push(getTranslationByName("keyPress", translations));
 							r.push('</td>');
							r.push('<td class="tablehead" width="20%">');
 							r.push(getTranslationByName("result", translations));
	 						r.push('</td>');
							r.push('</tr>');

 							for(var i = 0; i < bonus2Data.length; ++i)
 							{
 								r.push('<tr>');
								r.push('<td>');
								r.push(i+1);
								r.push('</td>');
 								r.push('<td>');
								if (bonus2Data[i] == "M")
								{
									r.push(getTranslationByName("plus1Multiplier", translations));
									multiplier++;
								}
								else if (bonus2Data[i] == "X")
								{
									r.push(getTranslationByName("collect", translations));
								}
								else
								{
									if (muliplierPrizes.indexOf(bonus2Data[i]) != -1)
									{
 										r.push(convertedPrizeValues[getPrizeNameIndex(prizeNames, bonus2Data[i])]);
									}
								}
 								r.push('</td>');
								r.push('</tr>');
 							}
							r.push('<tr>');
							r.push('<td class="tablebody" width="25%">');
							r.push(getTranslationByName("finalMultiplier", translations) + " " + multiplier + "x");
							r.push('</td>');

							r.push('</table>');
							r.push('&nbsp;');
						}

						// Additional Debug for test only
					//	r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
					//	r.push('<tr>');
					//	r.push('<td>');
					//	r.push(JSON.stringify(jsonContext));
					//	r.push('</td>');
					//	r.push('</tr>');
					//	r.push('<tr>');
					//	r.push('<td>');
					//	r.push(JSON.stringify(translations));
					//	r.push('</td>');
					//	r.push('</tr>');
					//	r.push('<tr>');
					//	r.push('<td>');
					//	r.push(JSON.stringify(prizeTable));
					//	r.push('</td>');
					//	r.push('</tr>');
					//	r.push('<tr>');
					//	r.push('<td>');
					//	r.push(JSON.stringify(prizeValues));
					//	r.push('</td>');
					//	r.push('</tr>');
					//	r.push('<tr>');
					//	r.push('<td>');
					//	r.push(JSON.stringify(prizeNamesDesc));
					//	r.push('</td>');
					//	r.push('</tr>');
					//	r.push('</table>');
					//	r.push('&nbsp;');

					//	r.push('<iframe height="300px" width="100%" src="http://igtinstantwin.com/julianPoc.html" name="iframeSven"></iframe>'); // svens.server.com/softwareId/

						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// !DEBUG OUTPUT TABLE
						if(debugFlag)
						{
							// DEBUG TABLE
							//////////////////////////////////////
							r.push('<table border="0" cellpadding="2" cellspacing="1" width="100%" class="gameDetailsTable" style="table-layout:fixed">');
							for(var idx = 0; idx < debugFeed.length; ++idx)
 							{
								if(debugFeed[idx] == "")
									continue;
								r.push('<tr>');
 								r.push('<td class="tablebody">');
								r.push(debugFeed[idx]);
 								r.push('</td>');
 								r.push('</tr>');
							}
							r.push('</table>');
						}
						return r.join('');
					}

					// Input: A list of Price Points and the available Prize Structures for the game as well as the wagered price point
					// Output: A string of the specific prize structure for the wagered price point
					function retrievePrizeTable(pricePoints, prizeStructures, wageredPricePoint)
					{
						var pricePointList = pricePoints.split(",");
						var prizeStructStrings = prizeStructures.split("|");

						for(var i = 0; i < pricePoints.length; ++i)
						{
							if(wageredPricePoint == pricePointList[i])
							{
								return prizeStructStrings[i];
							}
						}
						return "";
					}

					// Input: Json document string containing 'scenario' at root level.
					// Output: Scenario value.
					function getScenario(jsonContext)
					{
						// Parse json and retrieve scenario string.
						var jsObj = JSON.parse(jsonContext);
						var scenario = jsObj.scenario;

						// Trim null from scenario string.
						scenario = scenario.replace(/\0/g, '');

						return scenario;
					}

					// Input: Json document string containing 'amount' at root level.
					// Output: Price Point value.
					function getPricePoint(jsonContext)
					{
						// Parse json and retrieve price point amount
						var jsObj = JSON.parse(jsonContext);
						var pricePoint = jsObj.amount;

						return pricePoint;
					}

					// Input: "23,9,31|8:E,35:E,4:D,13:D,37:G,..."
					// Output: ["23", "9", "31"]
					function getGameData(scenario)
					{
						var numsData = scenario.split("|")[0];
						return numsData.split("");
					}

					function getBonus1GameData(scenario)
					{
						var numsData = scenario.split("|")[1];
						var targetData = numsData.split(":");
						return targetData;
					}

					function getBonus2GameData(scenario)
					{
						var numsData = scenario.split("|")[2];
						return numsData.split(",");
					}

					function getPrizeAsFloat(prize)
					{
						var prizeFloat = parseFloat(prize.replace(/[^0-9-.]/g, ''));
						return prizeFloat;
					}
					
					// Input: "A,B,C,D,..." and "A"
					// Output: index number
					function getPrizeNameIndex(prizeNames, currPrize)
					{
						for(var i = 0; i < prizeNames.length; ++i)
						{
							if(prizeNames[i] == currPrize)
							{
								return i;
							}
						}
					}

					////////////////////////////////////////////////////////////////////////////////////////
					function registerDebugText(debugText)
					{
						debugFeed.push(debugText);
					}

					/////////////////////////////////////////////////////////////////////////////////////////
					function getTranslationByName(keyName, translationNodeSet)
					{
						var index = 1;
						while(index < translationNodeSet.item(0).getChildNodes().getLength())
						{
							var childNode = translationNodeSet.item(0).getChildNodes().item(index);
							
							if(childNode.name == "phrase" && childNode.getAttribute("key") == keyName)
							{
								registerDebugText("Child Node: " + childNode.name);
								return childNode.getAttribute("value");
							}
							index += 1;
						}
					}

					// Grab Wager Type
					// @param jsonContext String JSON results to parse and display.
					// @param translation Set of Translations for the game.
					function getType(jsonContext, translations)
					{
						// Parse json and retrieve wagerType string.
						var jsObj = JSON.parse(jsonContext);
						var wagerType = jsObj.wagerType;

						return getTranslationByName(wagerType, translations);
					}
					]]>
				</lxslt:script>
			</lxslt:component>

			<x:template match="root" mode="last">
				<table border="0" cellpadding="1" cellspacing="1" width="100%" class="gameDetailsTable">
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWager']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/WagerOutcome[@name='Game.Total']/@amount" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
					<tr>
						<td valign="top" class="subheader">
							<x:value-of select="//translation/phrase[@key='totalWins']/@value" />
							<x:value-of select="': '" />
							<x:call-template name="Utils.ApplyConversionByLocale">
								<x:with-param name="multi" select="/output/denom/percredit" />
								<x:with-param name="value" select="//ResultData/PrizeOutcome[@name='Game.Total']/@totalPay" />
								<x:with-param name="code" select="/output/denom/currencycode" />
								<x:with-param name="locale" select="//translation/@language" />
							</x:call-template>
						</td>
					</tr>
				</table>
			</x:template>

			<!-- TEMPLATE Match: digested/game -->
			<x:template match="//Outcome">
				<x:if test="OutcomeDetail/Stage = 'Scenario'">
					<x:call-template name="Scenario.Detail" />
				</x:if>
			</x:template>

			<!-- TEMPLATE Name: Scenario.Detail (base game) -->
			<x:template name="Scenario.Detail">
				<x:variable name="odeResponseJson" select="string(//ResultData/JSONOutcome[@name='ODEResponse']/text())" />
				<x:variable name="translations" select="lxslt:nodeset(//translation)" />
				<x:variable name="wageredPricePoint" select="string(//ResultData/WagerOutcome[@name='Game.Total']/@amount)" />
				<x:variable name="prizeTable" select="lxslt:nodeset(//lottery)" />

				<table border="0" cellpadding="0" cellspacing="0" width="100%" class="gameDetailsTable">
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='wagerType']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="my-ext:getType($odeResponseJson, $translations)" disable-output-escaping="yes" />
						</td>
					</tr>
					<tr>
						<td class="tablebold" background="">
							<x:value-of select="//translation/phrase[@key='transactionId']/@value" />
							<x:value-of select="': '" />
							<x:value-of select="OutcomeDetail/RngTxnId" />
						</td>
					</tr>
				</table>
				<br />			
				
				<x:variable name="convertedPrizeValues">
					<x:apply-templates select="//lottery/prizetable/prize" mode="PrizeValue"/>
				</x:variable>

				<x:variable name="prizeNames">
					<x:apply-templates select="//lottery/prizetable/description" mode="PrizeDescriptions"/>
				</x:variable>


				<x:value-of select="my-ext:formatJson($odeResponseJson, $translations, $prizeTable, string($convertedPrizeValues), string($prizeNames))" disable-output-escaping="yes" />
			</x:template>

			<x:template match="prize" mode="PrizeValue">
					<x:text>|</x:text>
					<x:call-template name="Utils.ApplyConversionByLocale">
						<x:with-param name="multi" select="/output/denom/percredit" />
					<x:with-param name="value" select="text()" />
						<x:with-param name="code" select="/output/denom/currencycode" />
						<x:with-param name="locale" select="//translation/@language" />
					</x:call-template>
			</x:template>
			<x:template match="description" mode="PrizeDescriptions">
				<x:text>,</x:text>
				<x:value-of select="text()" />
			</x:template>

			<x:template match="text()" />
		</x:stylesheet>
	</xsl:template>

	<xsl:template name="TemplatesForResultXSL">
		<x:template match="@aClickCount">
			<clickcount>
				<x:value-of select="." />
			</clickcount>
		</x:template>
		<x:template match="*|@*|text()">
			<x:apply-templates />
		</x:template>
	</xsl:template>
</xsl:stylesheet>
