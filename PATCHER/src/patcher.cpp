
#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>

#include <stdio.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <algorithm>
#include <time.h>

//-----------------------------------------------------------------------------

enum ProgressBarStates { isRight, isLeft };

const int Max_Str_Len = 256;

int Window_Width  = 1600;
int Window_Height = 1000;

long int GetFileSizeFromStat( FILE* file );
long int ReadAllFile        ( FILE* file, char** str );

int GetRandNum( int min, int max );

int ProgressBarHandler( sf::RectangleShape* progress_bar, 
                        sf::Vector2f*       progress_bar_size );

void CrackCOM();

//-----------------------------------------------------------------------------

int main()
{
    srand( time( NULL ) ); 
    
    sf::RenderWindow window( sf::VideoMode( Window_Width, Window_Height ), "CrackPook!" );
    window.setFramerateLimit(1);

    sf::Music music;
    music.openFromFile( "music.ogg" );
    music.play();

    sf::Vector2f       progress_bar_size( 0, 50 );
    sf::RectangleShape progress_bar( progress_bar_size );

    progress_bar.setPosition ( 0, Window_Height - progress_bar_size.y );
    progress_bar.setFillColor( sf::Color::Green );

    sf::Image mario_image;
    mario_image.loadFromFile( "mario.png" );

    sf::Texture mario_texture;
    mario_texture.loadFromImage( mario_image );

    sf::Vector2f mario_size( 170, 220 );
    sf::RectangleShape mario( mario_size );
    
    mario.setTexture ( &mario_texture );
    mario.setPosition( 0, Window_Height - mario_size.y - 50 );

    while( window.isOpen() )
    {
        sf::Event event;
        while( window.pollEvent(event) )
        {
            if( event.type == sf::Event::Closed ) window.close();
        }

        ProgressBarHandler( &progress_bar, &progress_bar_size );

        mario.setPosition( GetRandNum( 0, Window_Width  - mario_size.x ), 
                           GetRandNum( 0, Window_Height - mario_size.y - 50 ) );

        window.clear( sf::Color::White );
        window.draw( progress_bar );
        window.draw( mario );
        window.display();
    }

    CrackCOM();

    return 0;
}

//-----------------------------------------------------------------------------

int ProgressBarHandler( sf::RectangleShape* progress_bar, 
                        sf::Vector2f*       progress_bar_size )
{
    static bool progress_bar_state = ProgressBarStates::isRight;
    static int  curr_size          = 0;
    
    if( progress_bar_state == ProgressBarStates::isRight )
        {
            if( curr_size < Window_Width )
            {
                curr_size += 100;
                if( curr_size > Window_Width ) curr_size = Window_Width; 
            }
            else
            {
                progress_bar_state = ProgressBarStates::isLeft;
            }
        }
        else
        {
            if( curr_size > 0 )
            {
                curr_size -= 100;
                if( curr_size < 0 ) curr_size = 0; 
            }
            else
            {
                progress_bar_state = ProgressBarStates::isRight;
            }
        }

        progress_bar->setSize( sf::Vector2f( curr_size, progress_bar->getSize().y ) );

        return 0;
}

//-----------------------------------------------------------------------------

void CrackCOM()
{
    char  com_file_name[Max_Str_Len] = "../EGORIKK/MAIN.COM";
    FILE* com_file = fopen( com_file_name, "rb" );

    char* buffer = "";
    int   file_size = ReadAllFile( com_file, &buffer ); 

    char  new_com_file_name[Max_Str_Len] = "MAIN_NEW.COM";
    FILE* new_com_file = fopen( new_com_file_name, "wb" );
    
    char new_ops[] = { char(0xBE), char(0x34), char(0x01),
                       char(0xFF), char(0xE6) };

    memcpy( buffer + 0x20, new_ops, sizeof( new_ops ) );
    
    fwrite( buffer, file_size, sizeof( *buffer ), new_com_file );

    fclose(     com_file );
    fclose( new_com_file );
}

//-----------------------------------------------------------------------------

long int GetFileSizeFromStat( FILE* file ) 
{
    //{ ASSERT
    assert( file != NULL );
    //}

    struct stat fileInfo = {};

    fstat( fileno( file ), &fileInfo );

    long int fileSize = fileInfo.st_size;

    return fileSize;
} 

//-----------------------------------------------------------------------------

long int ReadAllFile( FILE* file, char** str )
{
    // ASSERT
    assert (file != NULL);
    assert (str  != NULL);
    //

    long int fileSize = GetFileSizeFromStat( file );
    
    *str = ( char* )calloc( sizeof( char ), fileSize + 1 );

    long int rightRead = fread( *str, sizeof( char ), fileSize, file );

    if( rightRead < fileSize )
        realloc( str, sizeof( char ) * ( rightRead + 1 ) ); // Windows specific, \r remove

    (*str)[rightRead] = '\0';

    return rightRead;
}

//-----------------------------------------------------------------------------

int GetRandNum( int min, int max )
{
    return rand() % ( max - min + 1 )+ min;
}  

//-----------------------------------------------------------------------------