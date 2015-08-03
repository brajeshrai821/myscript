<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:nma="urn:nm-autobuild-schema">
<xsl:output method="text" encoding="iso-8859-1"/>

<xsl:template match="/">
  <xsl:if test="nma:nm-autobuild/@comment != ''">
    <xsl:text># </xsl:text>
    <xsl:value-of select="nma:nm-autobuild/@comment"/>
    <xsl:text>&#xa;</xsl:text>
  </xsl:if>
  <xsl:for-each select="nma:nm-autobuild/nma:group">
    <xsl:value-of select="@name"/> <xsl:text> {&#xa;</xsl:text>
    <xsl:for-each select="nma:param">
      <xsl:text>  </xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>=</xsl:text>
      <xsl:choose>
        <xsl:when test="@type = 'bool'">
          <xsl:value-of select="@value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>"</xsl:text>
          <xsl:value-of select="@value"/>
          <xsl:text>"</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@comment != ''">
        <xsl:text> # </xsl:text>
        <xsl:value-of select="@comment"/>
      </xsl:if>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
    <xsl:text>}&#xa;&#xa;</xsl:text>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>