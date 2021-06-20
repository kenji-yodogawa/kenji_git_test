<%--2012-11-28 author M.Kaneshi  画面下に日時を表示--%>
<%@ page  contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
DateFormat mDf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
Date mDate = new Date();
String mDateStr = mDf.format(mDate);
%>
<%=mDateStr %>