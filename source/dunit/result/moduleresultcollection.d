/**
 * Module for the module result collection.
 *
 * License:
 *     MIT. See LICENSE for full details.
 */
module dunit.result.moduleresultcollection;

/**
 * Imports.
 */
import dunit.result.moduleresult;
import std.algorithm;
import std.array;
import std.range;

/**
 * A class to hold module results.
 */
class ModuleResultCollection
{
	/**
	 * Collection of module results.
	 */
	private ModuleResult[] _results;

	/**
	 * Indicate if the results where all successful.
	 *
	 * Returns:
	 *     true if the results where successful, false if not.
	 */
	public @property bool allSuccessful()
	{
		foreach (result; this._results.retro())
		{
			if (result.error)
			{
				return false;
			}
		}
		return true;
	}

	/**
	 * The total number of tests run.
	 *
	 * Returns:
	 *     the number of tests that dunit has run.
	 */
	public @property size_t total()
	{
		return this._results.retro().length;
	}

	/**
	 * The amount of tests that contain a DUnitAssertError.
	 *
	 * Returns:
	 *     the number of tests that have failed.
	 */
	public @property size_t failed()
	{
		return this._results.retro().count!(result => result.error !is null);
	}

	/**
	 * The amount of tests that don't contain a DUnitAssertError.
	 *
	 * Returns:
	 *     the number of tests that have passed.
	 */
	public @property size_t passed()
	{
		return this._results.retro().count!(result => result.error is null);
	}

	/**
	 * Indicate if the collection is empty.
	 *
	 * Returns:
	 *     true if the collection is empty, false if not.
	 */
	public @property bool empty()
	{
		return this._results.empty();
	}

	/**
	 * Add a result to the collection.
	 *
	 * This method also sorts the collection by source and makes sure all results containing errors are at the end.
	 * This enables the console output to be more user friendly.
	 *
	 * Params:
	 *     result = The module result to add.
	 */
	public void add(ModuleResult result)
	{
		this._results ~= result;
		this._results.multiSort!("a.error is null && b.error !is null", "a.source < b.source")();
	}

	/**
	 * Overload slicing.
	 *
	 * Returns:
	 *     The internal collection of module results.
	 */
	public ModuleResult[] opSlice()
	{
		return this._results;
	}

	/**
	 * Overload indexing.
	 *
	 * Params:
	 *     index = The index of the collection.
	 *
	 * Returns:
	 *     The module result residing at the passed index.
	 */
	public ModuleResult opIndex(size_t index)
	{
		return this._results[index];
	}
}

unittest
{
	import dunit.error;
	import dunit.toolkit;

	auto results = new ModuleResultCollection();
	results.empty.assertTrue();

	results.add(new ModuleResult("Module1"));
	results.allSuccessful.assertTrue();

	results.add(new ModuleResult("Module2", new DUnitAssertError("Message", "file.d", 1)));
	results.allSuccessful.assertFalse();

	results.empty.assertFalse();
	results[].assertCount(2);

	results[0].source.assertEqual("Module1");
	results[0].error.assertNull();
	results[1].source.assertEqual("Module2");
	results[1].error.assertType!(DUnitAssertError)();
}
