package compile.antlr;

public class StrEval
{
	public static String and(String left, String right)
	{
		return getBoolean(left) && getBoolean(right)? "true" : "false";
	}

	public static String or(String left, String right)
	{
		return getBoolean(left) || getBoolean(right)? "true" : "false";
	}

	public static String eq(String left, String right)
	{
		return left.equals(right)? "true" : "false";
	}

	public static String neq(String left, String right)
	{
		return !left.equals(right)? "true" : "false";
	}

	public static String lt(String left, String right)
	{
		return getInt(left) < getInt(right)? "true" : "false";
	}

	public static String gt(String left, String right)
	{
		return getInt(left) > getInt(right)? "true" : "false";
	}

	public static String lteq(String left, String right)
	{
		return getInt(left) <= getInt(right)? "true" : "false";
	}

	public static String gteq(final String left, String right)
	{
		return getInt(left) >= getInt(right)? "true" : "false";
	}

	public static String n(String str)
	{
		return !getBoolean(str)? "true" : "false";
	}

	public static int getInt(String str)
	{
		try
		{
			return Integer.parseInt(str);
		}
		catch (Exception e)
		{
			return 0;
		}
	}

	public static boolean getBoolean(String str)
	{
		try
		{
			if (Integer.parseInt(str) == 0)
			{
				return false;
			}

			return true;
		}
		catch (Exception e)
		{
			if (str == "false")
			{
				return false;
			}

			return true;
		}
	}
}
