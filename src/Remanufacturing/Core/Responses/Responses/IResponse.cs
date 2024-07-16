using System.Net;

namespace Remanufacturing.Responses;

/// <summary>
/// Represents a response object based off of the RFC 7807 specification.
/// </summary>
public interface IResponse
{

	/// <summary>
	/// A URI reference that identifies the response type. This specification encourages that, when dereferenced, it provide human-readable documentation for the response type.
	/// </summary>
	string Type { get; set; }

	/// <summary>
	/// A short, human-readable summary of the response. It SHOULD NOT change from occurrence to occurrence of the response type, except for purposes of localization.
	/// </summary>
	string Title { get; set; }

	/// <summary>
	/// The HTTP status code for the response.
	/// </summary>
	HttpStatusCode Status { get; set; }

	/// <summary>
	/// A human-readable explanation specific to this occurrence of the response.
	/// </summary>
	string? Detail { get; set; }

	/// <summary>
	/// A URI reference that identifies the specific occurrence of the response. It may or may not yield further information if dereferenced.
	/// </summary>
	string? Instance { get; set; }

	/// <summary>
	/// Additional details about the response that may be helpful when receiving the response.
	/// </summary>
	Dictionary<string, object>? Extensions { get; set; }

}