package;

#if windows
import Sys.sleep;
import discord_rpc.DiscordRpc;

using StringTools;

class DiscordClient
{
	public function new()
	{
		DiscordRpc.start({
			clientID: "865118720170786846", // Discord app ID
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
		}

		DiscordRpc.shutdown();
		return;
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
		return;
	}

	static function onReady()
	{
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "fridaynightfunkin"
		});
		return;
	}

	static function onError(_code:Int, _message:String)
	{
		return;
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		return;
	}

	public static function initialize()
	{
		sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		return;
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey : String, ?hasStartTimestamp : Bool, ?endTimestamp: Float)
	{
		var startTimestamp:Float = if(hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: "fridaynightfunkin",
			smallImageKey : smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		});

		return;
	}
}
#end