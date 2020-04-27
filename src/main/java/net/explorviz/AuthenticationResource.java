package net.explorviz;

import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.Consumes;
import javax.ws.rs.core.MediaType;

@Path("/secret")
public class AuthenticationResource {

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public String secret() {
        return "{\"htmlAuthentication\": \"Get Request\"}";
    }

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public String postSecret(Object something) {
        return "{\"htmlAuthentication\": \"Get Request\"}";
    }
}