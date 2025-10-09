using API.Authorization;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using OpenPolicyAgent.Opa;
using OpenPolicyAgent.Opa.AspNetCore;

string opaUrl = System.Environment.GetEnvironmentVariable("OPA_URL") ?? "http://opa:8181"; // niet localhost, omdat met aparte containers wordt gewerkt
OpaClient opa = new OpaClient(opaUrl);

var builder = WebApplication.CreateBuilder(args);

// Read values from appsettings.json
var jwtAuthority = builder.Configuration["Jwt:Authority"];
var jwtAudience = builder.Configuration["Jwt:Audience"];
var corsOrigin = builder.Configuration["Cors:Origin"];

// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    options.Authority = jwtAuthority;
    options.Audience = jwtAudience;

});

builder.Services.AddHttpContextAccessor();

// de controle op leeftijd gebeurt voortaan dmv OPA
// builder.Services.AddAuthorization(options =>
// {
//     options.FallbackPolicy = new AuthorizationPolicyBuilder()
//         .RequireAuthenticatedUser()
//         .Build();
//     options.AddPolicy("Over16Only", policy =>
//             policy.Requirements.Add(new AgeRequirement(16)));
// });
// builder.Services.AddSingleton<IAuthorizationHandler, AgeHandler>();


var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseCors(options => options
    .WithOrigins(corsOrigin)
    .AllowAnyMethod()
    .AllowAnyHeader());

app.UseAuthentication();
// app.UseAuthorization(); // authorization gebeurt voortaan dmv OPA
app.UseMiddleware<OpaAuthorizationMiddleware>(opa, "authz/exampleapp/routes/allow");

app.MapControllers();

app.Run();
