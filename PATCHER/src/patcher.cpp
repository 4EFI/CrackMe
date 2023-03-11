#include <SFML/Graphics.hpp>

int main()
{
    int window_width  = 1000;
    int window_height = 600; 
    
    sf::RenderWindow window( sf::VideoMode( window_width, 
                                            window_height ), 
                            "CrackPook!" );

    sf::CircleShape shape(100.f);
    shape.setFillColor(sf::Color::Green);

    while( window.isOpen() )
    {
        sf::Event event;
        while( window.pollEvent(event) )
        {
            if( event.type == sf::Event::Closed ) window.close();
        }



        window.clear();
        window.display();
    }

    return 0;
}